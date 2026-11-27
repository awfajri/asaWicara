import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/patient_repository.dart';
import '../../domain/models/patient_model.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final PatientRepository _patientRepository;

  PatientCubit({required PatientRepository patientRepository})
    : _patientRepository = patientRepository,
      super(const PatientState());

  Future<void> loadPatients(String caregiverId) async {
    emit(state.copyWith(status: PatientStatus.loading, errorMessage: null));
    try {
      final list = await _patientRepository.fetchPatientsByCaregiver(
        caregiverId,
      );

      PatientModel? nextActive = state.activePatient;
      if (nextActive != null) {
        final matches = list.where((patient) => patient.id == nextActive!.id);
        nextActive = matches.isNotEmpty ? matches.first : null;
      }
      nextActive ??= list.isNotEmpty ? list.first : null;

      emit(
        state.copyWith(
          status: PatientStatus.loaded,
          patients: list,
          activePatient: nextActive,
          clearActivePatient: nextActive == null,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: PatientStatus.error, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PatientStatus.error,
          errorMessage: 'Tidak dapat memuat daftar pasien.',
        ),
      );
    }
  }

  void selectActivePatient(PatientModel patient) {
    emit(state.copyWith(activePatient: patient, errorMessage: null));
  }

  void enterPatientMode() {
    if (state.activePatient == null) return;
    emit(state.copyWith(isPatientModeActive: true));
  }

  void exitPatientMode() {
    emit(state.copyWith(isPatientModeActive: false));
  }

  Future<bool> addPatient({
    required String caregiverId,
    required String fullName,
    required String nickname,
    DateTime? birthDate,
    String? gender,
    required String relationship,
    String? notes,
  }) async {
    emit(state.copyWith(status: PatientStatus.saving, errorMessage: null));
    try {
      final created = await _patientRepository.createPatient(
        caregiverId: caregiverId,
        fullName: fullName,
        nickname: nickname,
        birthDate: birthDate,
        gender: gender,
        relationship: relationship,
        notes: notes,
      );
      emit(
        state.copyWith(
          status: PatientStatus.loaded,
          patients: [...state.patients, created],
          activePatient: created,
        ),
      );
      return true;
    } on AppException catch (e) {
      emit(
        state.copyWith(status: PatientStatus.error, errorMessage: e.message),
      );
      return false;
    }
  }

  Future<bool> editPatient(PatientModel updatedPatient) async {
    emit(state.copyWith(status: PatientStatus.saving, errorMessage: null));
    try {
      final saved = await _patientRepository.updatePatient(updatedPatient);
      final updatedList = state.patients
          .map((patient) => patient.id == saved.id ? saved : patient)
          .toList();
      final nextActive = state.activePatient?.id == saved.id
          ? saved
          : state.activePatient;

      emit(
        state.copyWith(
          status: PatientStatus.loaded,
          patients: updatedList,
          activePatient: nextActive,
        ),
      );
      return true;
    } on AppException catch (e) {
      emit(
        state.copyWith(status: PatientStatus.error, errorMessage: e.message),
      );
      return false;
    }
  }

  void reset() {
    emit(const PatientState());
  }
}
