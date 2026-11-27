import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/models/patient_model.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/patient_state.dart';

class PatientFormPage extends StatefulWidget {
  final PatientModel? initialPatient;

  const PatientFormPage({super.key, this.initialPatient});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _relationshipCtrl;
  late final TextEditingController _notesCtrl;
  DateTime _birthDate = DateTime(1958, 5, 15);
  String _gender = 'P';

  bool get _isEditing => widget.initialPatient != null;

  @override
  void initState() {
    super.initState();
    final patient = widget.initialPatient;
    _nameCtrl = TextEditingController(text: patient?.fullName ?? '');
    _nicknameCtrl = TextEditingController(text: patient?.nickname ?? '');
    _relationshipCtrl = TextEditingController(
      text: patient?.relationship ?? 'Ibu',
    );
    _notesCtrl = TextEditingController(text: patient?.notes ?? '');
    if (patient?.birthDate != null) _birthDate = patient!.birthDate!;
    if (patient?.gender != null) _gender = patient!.gender!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _relationshipCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir Pasien',
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final caregiverId = context.read<AuthBloc>().state.caregiver?.id;
    if (caregiverId == null) return;

    final cubit = context.read<PatientCubit>();
    bool success;
    if (_isEditing) {
      success = await cubit.editPatient(
        widget.initialPatient!.copyWith(
          fullName: _nameCtrl.text.trim(),
          nickname: _nicknameCtrl.text.trim(),
          birthDate: _birthDate,
          gender: _gender,
          relationship: _relationshipCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
        ),
      );
    } else {
      success = await cubit.addPatient(
        caregiverId: caregiverId,
        fullName: _nameCtrl.text.trim(),
        nickname: _nicknameCtrl.text.trim(),
        birthDate: _birthDate,
        gender: _gender,
        relationship: _relationshipCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
    }

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PatientCubit>().state;
    final isSaving = state.status == PatientStatus.saving;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ubah Profil Pasien' : 'Tambah Pasien Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status == PatientStatus.error &&
                    state.errorMessage != null) ...[
                  GeriatricInfoBanner(
                    title: 'Gagal Menyimpan',
                    message: state.errorMessage!,
                    icon: Icons.error_outline_rounded,
                    backgroundColor: AppColors.dangerContainer,
                    iconColor: AppColors.danger,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap Pasien',
                    prefixIcon: Icon(Icons.elderly_rounded, size: 26),
                  ),
                  validator: (value) => value == null || value.trim().length < 2
                      ? 'Nama pasien wajib diisi.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Panggilan (Contoh: Bu Ncu)',
                    prefixIcon: Icon(Icons.face_rounded, size: 26),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama panggilan wajib diisi.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _relationshipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hubungan dengan Pendamping',
                    prefixIcon: Icon(Icons.people_outline_rounded, size: 26),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Hubungan wajib diisi.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: Icon(Icons.wc_rounded, size: 26),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _gender = value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      prefixIcon: Icon(Icons.calendar_month_rounded, size: 26),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormatter.formatDateOnly(_birthDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Text(
                          'Ubah',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Pendampingan (Opsional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GeriatricPrimaryButton(
                  label: _isEditing
                      ? 'Simpan Perubahan Pasien'
                      : 'Simpan Pasien Baru',
                  icon: Icons.save_outlined,
                  isLoading: isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
