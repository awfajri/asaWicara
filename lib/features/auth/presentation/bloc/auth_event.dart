import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthCompleteProfileSubmitted extends AuthEvent {
  final String caregiverFullName;
  final String? phone;
  final String firstPatientName;
  final String firstPatientNickname;
  final DateTime? firstPatientBirthDate;
  final String? firstPatientGender;
  final String relationship;

  const AuthCompleteProfileSubmitted({
    required this.caregiverFullName,
    this.phone,
    required this.firstPatientName,
    required this.firstPatientNickname,
    this.firstPatientBirthDate,
    this.firstPatientGender,
    required this.relationship,
  });

  @override
  List<Object?> get props => [
    caregiverFullName,
    phone,
    firstPatientName,
    firstPatientNickname,
    firstPatientBirthDate,
    firstPatientGender,
    relationship,
  ];
}

class AuthForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const AuthForgotPasswordSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
