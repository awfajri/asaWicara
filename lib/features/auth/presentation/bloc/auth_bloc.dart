import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../patient/data/patient_repository.dart';
import '../../domain/models/caregiver_model.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final PatientRepository _patientRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required PatientRepository patientRepository,
  }) : _authRepository = authRepository,
       _patientRepository = patientRepository,
       super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthCompleteProfileSubmitted>(_onCompleteProfileSubmitted);
    on<AuthForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Menentukan tujuan setelah login/cek sesi: profil belum lengkap atau
  /// belum punya pasien -> Complete Profile, selain itu -> Dashboard.
  Future<AuthState> _resolveState(CaregiverModel caregiver) async {
    if (!caregiver.isProfileCompleted) {
      return AuthState(
        status: AuthStatus.needsProfileCompletion,
        caregiver: caregiver,
      );
    }
    final patients = await _patientRepository.fetchPatientsByCaregiver(
      caregiver.id,
    );
    if (patients.isEmpty) {
      return AuthState(
        status: AuthStatus.needsProfileCompletion,
        caregiver: caregiver,
      );
    }
    return AuthState(status: AuthStatus.authenticated, caregiver: caregiver);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final caregiver = await _authRepository.getCurrentCaregiver();
      if (caregiver == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      emit(await _resolveState(caregiver));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final caregiver = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(await _resolveState(caregiver));
    } on AppException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final caregiver = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(
        AuthState(
          status: AuthStatus.needsProfileCompletion,
          caregiver: caregiver,
        ),
      );
    } on AppException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onCompleteProfileSubmitted(
    AuthCompleteProfileSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state.caregiver;
    if (current == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final updatedCaregiver = await _authRepository.completeCaregiverProfile(
        caregiverId: current.id,
        fullName: event.caregiverFullName,
        phone: event.phone,
      );

      await _patientRepository.createPatient(
        caregiverId: current.id,
        fullName: event.firstPatientName,
        nickname: event.firstPatientNickname,
        birthDate: event.firstPatientBirthDate,
        gender: event.firstPatientGender,
        relationship: event.relationship,
      );

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          caregiver: updatedCaregiver,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
    AuthForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);
      emit(const AuthState(status: AuthStatus.passwordResetSent));
    } on AppException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
