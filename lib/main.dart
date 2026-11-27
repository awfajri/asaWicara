import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

String get _effectiveSupabaseKey => _supabasePublishableKey.isNotEmpty
    ? _supabasePublishableKey
    : _supabaseAnonKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseKey = _effectiveSupabaseKey;
  if (_supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    runApp(const _MissingConfigApp());
    return;
  }

  await initializeDateFormatting('id_ID');
  await Supabase.initialize(url: _supabaseUrl, publishableKey: supabaseKey);

  runApp(AsaWicaraApp(dependencies: AppDependencies.create()));
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Konfigurasi Supabase belum terbaca.\n'
              'Jalankan aplikasi dengan --dart-define-from-file=env.json',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
