import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/patient/data/patient_repository.dart';

/// Menyatukan seluruh repository dari satu SupabaseClient.
/// Repository Exercise, History, dan AudioService ditambahkan di fase berikutnya.
class AppDependencies {
  final SupabaseClient client;
  final AuthRepository authRepository;
  final PatientRepository patientRepository;

  AppDependencies._({
    required this.client,
    required this.authRepository,
    required this.patientRepository,
  });

  factory AppDependencies.create() {
    final client = Supabase.instance.client;
    return AppDependencies._(
      client: client,
      authRepository: AuthRepository(client),
      patientRepository: PatientRepository(client),
    );
  }
}
