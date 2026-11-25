import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/models/caregiver_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  const AuthRepository(this._client);

  Future<CaregiverModel?> getCurrentCaregiver() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _client
          .from('caregivers')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Fallback aman jika trigger belum selesai menulis baris
        final inserted = await _client
            .from('caregivers')
            .upsert({
              'id': user.id,
              'email': user.email ?? '',
              'full_name': '',
              'is_profile_completed': false,
            })
            .select()
            .single();
        return CaregiverModel.fromJson(inserted);
      }

      return CaregiverModel.fromJson(data);
    } catch (_) {
      throw const AppException(
        'Gagal memuat data akun pendamping. Periksa koneksi internet Anda.',
      );
    }
  }

  Future<CaregiverModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        throw const AppException('Gagal masuk ke akun pendamping.');
      }
      final caregiver = await getCurrentCaregiver();
      if (caregiver == null) {
        throw const AppException('Data profil pendamping tidak ditemukan.');
      }
      return caregiver;
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message), code: e.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Terjadi kendala saat masuk. Periksa jaringan internet Anda.',
      );
    }
  }

  Future<CaregiverModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AppException('Pendaftaran gagal dibuat.');
      }

      // Jika "Confirm email" aktif di Supabase, sesi tidak langsung dibuat
      // sehingga Complete Profile akan ditolak RLS. Beri pesan yang jelas.
      if (response.session == null) {
        throw const AppException(
          'Akun dibuat, tetapi sesi belum aktif. Nonaktifkan "Confirm email" '
          'di Supabase (Authentication > Providers > Email) untuk mode MVP.',
        );
      }

      // Trigger SQL membuat baris di tabel caregivers otomatis.
      final caregiver = await getCurrentCaregiver();
      if (caregiver != null) return caregiver;

      final now = DateTime.now();
      return CaregiverModel(
        id: user.id,
        fullName: '',
        email: email.trim(),
        isProfileCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message), code: e.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Gagal mendaftarkan akun baru.');
    }
  }

  Future<CaregiverModel> completeCaregiverProfile({
    required String caregiverId,
    required String fullName,
    String? phone,
  }) async {
    try {
      final updated = await _client
          .from('caregivers')
          .update({
            'full_name': fullName.trim(),
            'phone': (phone?.trim().isEmpty ?? true) ? null : phone!.trim(),
            'is_profile_completed': true,
          })
          .eq('id', caregiverId)
          .select()
          .single();

      return CaregiverModel.fromJson(updated);
    } catch (_) {
      throw const AppException('Gagal menyimpan profil pendamping.');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message), code: e.statusCode);
    } catch (_) {
      throw const AppException('Gagal mengirim tautan pemulihan kata sandi.');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _mapAuthError(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email atau kata sandi belum tepat. Silakan periksa kembali.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan masuk menggunakan akun tersebut.';
    }
    if (lower.contains('password should be at least')) {
      return 'Kata sandi minimal harus terdiri dari 6 karakter.';
    }
    return rawMessage;
  }
}
