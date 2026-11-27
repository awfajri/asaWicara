import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_secondary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../patient/presentation/cubit/patient_cubit.dart';

class CaregiverProfilePage extends StatelessWidget {
  const CaregiverProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Anda harus masuk kembali menggunakan email dan kata sandi untuk mengakses data pasien.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(fontSize: 17)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<PatientCubit>().reset();
      context.read<AuthBloc>().add(const AuthLogoutRequested());
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = context.select((AuthBloc b) => b.state.caregiver);
    final totalPatients = context.select(
      (PatientCubit c) => c.state.patients.length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan Pendamping')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caregiver?.fullName ?? 'Pendamping',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Email: ${caregiver?.email ?? "-"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (caregiver?.phone != null &&
                          caregiver!.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Telepon: ${caregiver.phone}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Jumlah Pasien Terdaftar: $totalPatients orang',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const GeriatricInfoBanner(
                title: 'Tentang AsaWicara',
                message: AppConstants.nonDiagnosticDisclaimer,
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.xl),
              GeriatricSecondaryButton(
                label: 'Keluar dari Akun (Logout)',
                icon: Icons.logout_rounded,
                borderColor: AppColors.danger,
                textColor: AppColors.danger,
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
