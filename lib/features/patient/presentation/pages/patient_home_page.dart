import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../../../../core/widgets/geriatric_secondary_button.dart';
import '../../../caregiver/presentation/widgets/exit_patient_mode_dialog.dart';
import '../cubit/patient_cubit.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  String _greetingByHour() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> _handleExitPatientMode(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitPatientModeDialog(),
    );
    if (shouldExit == true && context.mounted) {
      context.read<PatientCubit>().exitPatientMode();
      context.go('/caregiver/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePatient = context.select(
      (PatientCubit cubit) => cubit.state.activePatient,
    );
    final nickname = activePatient?.nickname ?? 'Bapak/Ibu';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExitPatientMode(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mode Latihan Pasien'),
          actions: [
            TextButton.icon(
              onPressed: () => _handleExitPatientMode(context),
              icon: const Icon(Icons.lock_open_rounded, size: 22),
              label: const Text(
                'Mode Pendamping',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: AppColors.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greetingByHour()}, $nickname!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Mari berlatih mengucapkan huruf vokal A, I, U, E, dan O dengan tenang dan jelas.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GeriatricPrimaryButton(
                  label: 'Mulai Latihan AIUEO Sekarang',
                  icon: Icons.record_voice_over_rounded,
                  onPressed: () => context.push('/patient/exercise'),
                ),
                const SizedBox(height: AppSpacing.md),
                GeriatricSecondaryButton(
                  label: 'Lihat Riwayat Latihan Saya',
                  icon: Icons.history_rounded,
                  onPressed: () => context.push('/history'),
                ),
                const SizedBox(height: AppSpacing.xl),
                const GeriatricInfoBanner(
                  title: 'Tips Latihan Nyaman',
                  message:
                      'Duduk dengan posisi tegak yang santai, tarik napas perlahan sebelum berbicara, dan tidak perlu terburu-buru.',
                  icon: Icons.favorite_outline_rounded,
                  backgroundColor: AppColors.secondaryContainer,
                  iconColor: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
