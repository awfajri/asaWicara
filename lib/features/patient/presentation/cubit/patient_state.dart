import 'package:equatable/equatable.dart';

import '../../domain/models/patient_model.dart';

enum PatientStatus { initial, loading, loaded, saving, error }

class PatientState extends Equatable {
  final PatientStatus status;
  final List<PatientModel> patients;
  final PatientModel? activePatient;
  final bool isPatientModeActive;
  final String? errorMessage;

  const PatientState({
    this.status = PatientStatus.initial,
    this.patients = const [],
    this.activePatient,
    this.isPatientModeActive = false,
    this.errorMessage,
  });

  PatientState copyWith({
    PatientStatus? status,
    List<PatientModel>? patients,
    PatientModel? activePatient,
    bool clearActivePatient = false,
    bool? isPatientModeActive,
    String? errorMessage,
  }) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      activePatient: clearActivePatient
          ? null
          : (activePatient ?? this.activePatient),
      isPatientModeActive: isPatientModeActive ?? this.isPatientModeActive,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    patients,
    activePatient,
    isPatientModeActive,
    errorMessage,
  ];
}
