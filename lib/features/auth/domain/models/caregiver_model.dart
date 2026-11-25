import 'package:equatable/equatable.dart';

class CaregiverModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final bool isProfileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CaregiverModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.isProfileCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return CaregiverModel(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      isProfileCompleted: (json['is_profile_completed'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse((json['created_at'] as String?) ?? '') ?? now,
      updatedAt:
          DateTime.tryParse((json['updated_at'] as String?) ?? '') ?? now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'is_profile_completed': isProfileCompleted,
    };
  }

  CaregiverModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    bool? isProfileCompleted,
    DateTime? updatedAt,
  }) {
    return CaregiverModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    isProfileCompleted,
    createdAt,
    updatedAt,
  ];
}
