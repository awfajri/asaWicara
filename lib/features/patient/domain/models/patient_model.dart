import 'package:equatable/equatable.dart';

class PatientModel extends Equatable {
  final String id;
  final String caregiverId;
  final String fullName;
  final String nickname;
  final DateTime? birthDate;
  final String? gender;
  final String relationship;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientModel({
    required this.id,
    required this.caregiverId,
    required this.fullName,
    required this.nickname,
    this.birthDate,
    this.gender,
    required this.relationship,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  int? get ageYears {
    final dob = birthDate;
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return PatientModel(
      id: json['id'] as String,
      caregiverId: json['caregiver_id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      relationship: (json['relationship'] as String?) ?? 'Keluarga',
      notes: json['notes'] as String?,
      createdAt:
          DateTime.tryParse((json['created_at'] as String?) ?? '') ?? now,
      updatedAt:
          DateTime.tryParse((json['updated_at'] as String?) ?? '') ?? now,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'full_name': fullName,
      'nickname': nickname,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'gender': gender,
      'relationship': relationship,
      'notes': notes,
    };
  }

  PatientModel copyWith({
    String? fullName,
    String? nickname,
    DateTime? birthDate,
    String? gender,
    String? relationship,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id,
      caregiverId: caregiverId,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    caregiverId,
    fullName,
    nickname,
    birthDate,
    gender,
    relationship,
    notes,
    createdAt,
    updatedAt,
  ];
}
