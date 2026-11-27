import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../../../../core/widgets/geriatric_secondary_button.dart';
import '../../../../core/widgets/state_feedback_views.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../patient/presentation/cubit/patient_cubit.dart';
import '../../../patient/presentation/cubit/patient_state.dart';
import '../widgets/patient_switcher_card.dart';

class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final caregiver = context.select((AuthBloc b) => b.state.caregiver);
    final patientState = context.watch<PatientCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Pendamping'),
        actions: [
          IconButton(
            tooltip: 'Profil & Pengaturan Pendamping',
            iconSize: 30,
            onPressed: () => context.push('/caregiver/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (patientState.status == PatientStatus.loading &&
                patientState.patients.isEmpty) {
              return const GeriatricLoadingView(
                message: 'Memuat data pasien pendampingan...',
              );
            }

            if (patientState.status == PatientStatus.error &&
                patientState.patients.isEmpty) {
              return GeriatricErrorView(
                message:
                    patientState.errorMessage ?? 'Gagal memuat daftar pasien.',
                onRetry: () {
                  if (caregiver != null) {
                    context.read<PatientCubit>().loadPatients(caregiver.id);
                  }
                },
              );
            }

            final activePatient = patientState.activePatient;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${caregiver?.fullName.isNotEmpty == true ? caregiver!.fullName : "Pendamping"}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih profil lansia di bawah ini untuk memulai latihan atau melihat riwayat sesi.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PatientSwitcherCard(
                    patients: patientState.patients,
                    activePatient: activePatient,
                    onSelectPatient: (patient) => context
                        .read<PatientCubit>()
                        .selectActivePatient(patient),
                    onAddPatient: () => context.push('/patient/form'),
                    onEditActivePatient: activePatient == null
                        ? null
                        : () => context.push(
                            '/patient/form',
                            extra: activePatient,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (activePatient != null) ...[
                    GeriatricPrimaryButton(
                      label: 'Masuk Mode Pasien (${activePatient.nickname})',
                      icon: Icons.elderly_rounded,
                      onPressed: () {
                        context.read<PatientCubit>().enterPatientMode();
                        context.go('/patient/home');
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GeriatricSecondaryButton(
                      label: 'Lihat Riwayat & Rekaman Suara',
                      icon: Icons.history_rounded,
                      onPressed: () => context.push('/history'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const GeriatricInfoBanner(
                    title: 'Catatan Pendampingan',
                    message: AppConstants.nonDiagnosticDisclaimer,
                    icon: Icons.verified_user_outlined,
                    backgroundColor: AppColors.secondaryContainer,
                    iconColor: AppColors.secondary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
