import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_secondary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Placeholder Fase 1. Akan diganti penuh pada Fase 2
/// (Patient Switcher, Mode Pasien, ringkasan aktivitas).
class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final caregiver = context.select((AuthBloc b) => b.state.caregiver);
    return Scaffold(
      appBar: AppBar(title: const Text('Dasbor Pendamping')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${caregiver?.fullName ?? ''}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Dasbor lengkap hadir di Fase 2.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              GeriatricSecondaryButton(
                label: 'Keluar Akun',
                icon: Icons.logout_rounded,
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
