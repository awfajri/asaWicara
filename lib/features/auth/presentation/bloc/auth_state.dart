import 'package:equatable/equatable.dart';

import '../../domain/models/caregiver_model.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  needsProfileCompletion,
  authenticated,
  passwordResetSent,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final CaregiverModel? caregiver;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.caregiver,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    CaregiverModel? caregiver,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      caregiver: caregiver ?? this.caregiver,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, caregiver, errorMessage];
}
