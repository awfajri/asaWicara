import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/models/patient_model.dart';

class PatientRepository {
  final SupabaseClient _client;

  const PatientRepository(this._client);

  Future<List<PatientModel>> fetchPatientsByCaregiver(
    String caregiverId,
  ) async {
    try {
      final rows = await _client
          .from('patients')
          .select()
          .eq('caregiver_id', caregiverId)
          .order('created_at', ascending: true);

      return (rows as List<dynamic>)
          .map((row) => PatientModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const AppException('Gagal memuat daftar pasien.');
    }
  }

  Future<PatientModel> createPatient({
    required String caregiverId,
    required String fullName,
    required String nickname,
    DateTime? birthDate,
    String? gender,
    required String relationship,
    String? notes,
  }) async {
    try {
      final inserted = await _client
          .from('patients')
          .insert({
            'caregiver_id': caregiverId,
            'full_name': fullName.trim(),
            'nickname': nickname.trim(),
            'birth_date': birthDate?.toIso8601String().split('T').first,
            'gender': gender,
            'relationship': relationship.trim(),
            'notes': (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
          })
          .select()
          .single();

      return PatientModel.fromJson(inserted);
    } catch (_) {
      throw const AppException('Gagal menambahkan profil pasien.');
    }
  }

  Future<PatientModel> updatePatient(PatientModel patient) async {
    try {
      final updated = await _client
          .from('patients')
          .update(patient.toUpdateMap())
          .eq('id', patient.id)
          .select()
          .single();

      return PatientModel.fromJson(updated);
    } catch (_) {
      throw const AppException('Gagal memperbarui profil pasien.');
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      await _client.from('patients').delete().eq('id', patientId);
    } catch (_) {
      throw const AppException('Gagal menghapus profil pasien.');
    }
  }
}
