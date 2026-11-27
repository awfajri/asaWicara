import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../patient/domain/models/patient_model.dart';

class PatientSwitcherCard extends StatelessWidget {
  final List<PatientModel> patients;
  final PatientModel? activePatient;
  final ValueChanged<PatientModel> onSelectPatient;
  final VoidCallback onAddPatient;
  final VoidCallback? onEditActivePatient;

  const PatientSwitcherCard({
    super.key,
    required this.patients,
    required this.activePatient,
    required this.onSelectPatient,
    required this.onAddPatient,
    this.onEditActivePatient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pasien yang Didampingi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: onAddPatient,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (patients.isEmpty)
              Text(
                'Belum ada profil pasien. Tambahkan pasien pertama untuk memulai latihan.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: patients.map((patient) {
                  final isSelected = activePatient?.id == patient.id;
                  return ChoiceChip(
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceVariant,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    label: Text(
                      '${patient.nickname} (${patient.relationship})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    onSelected: (_) => onSelectPatient(patient),
                  );
                }).toList(),
              ),
            if (activePatient != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(
                        Icons.elderly_rounded,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activePatient!.fullName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            activePatient!.ageYears != null
                                ? 'Panggilan: ${activePatient!.nickname} • ${activePatient!.ageYears} tahun'
                                : 'Panggilan: ${activePatient!.nickname}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (onEditActivePatient != null)
                      IconButton(
                        tooltip: 'Ubah Profil Pasien',
                        iconSize: 28,
                        color: AppColors.primary,
                        onPressed: onEditActivePatient,
                        icon: const Icon(Icons.edit_note_rounded),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
