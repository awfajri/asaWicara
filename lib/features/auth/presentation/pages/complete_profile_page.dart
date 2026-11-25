import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _caregiverNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _patientNameCtrl = TextEditingController();
  final _patientNicknameCtrl = TextEditingController();
  final _relationshipCtrl = TextEditingController(text: 'Ibu / Ayah');
  DateTime _birthDate = DateTime(1958, 5, 15);
  String _gender = 'P';

  @override
  void dispose() {
    _caregiverNameCtrl.dispose();
    _phoneCtrl.dispose();
    _patientNameCtrl.dispose();
    _patientNicknameCtrl.dispose();
    _relationshipCtrl.dispose();
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
    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthCompleteProfileSubmitted(
        caregiverFullName: _caregiverNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        firstPatientName: _patientNameCtrl.text.trim(),
        firstPatientNickname: _patientNicknameCtrl.text.trim(),
        firstPatientBirthDate: _birthDate,
        firstPatientGender: _gender,
        relationship: _relationshipCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lengkapi Profil & Pasien')),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go('/caregiver/dashboard');
            }
          },
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah 2 dari 2: Data Pendamping & Lansia',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Anda dapat menambahkan lebih dari satu pasien lansia nanti melalui Dasbor Pendamping.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      GeriatricInfoBanner(
                        title: 'Gagal Menyimpan Profil',
                        message: state.errorMessage!,
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.dangerContainer,
                        iconColor: AppColors.danger,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '1. Profil Pendamping (Caregiver)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _caregiverNameCtrl,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Pendamping',
                        prefixIcon: Icon(Icons.badge_outlined, size: 26),
                      ),
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Nama pendamping wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Nomor HP (Opsional)',
                        prefixIcon: Icon(Icons.phone_outlined, size: 26),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      '2. Profil Pasien Lansia Pertama',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _patientNameCtrl,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Pasien',
                        prefixIcon: Icon(Icons.elderly_rounded, size: 26),
                      ),
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Nama lengkap pasien wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _patientNicknameCtrl,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Nama Panggilan (Contoh: Bu Ncu / Pak Budi)',
                        prefixIcon: Icon(Icons.face_rounded, size: 26),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama panggilan wajib diisi untuk sapaan.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _relationshipCtrl,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Hubungan dengan Pendamping',
                        prefixIcon: Icon(
                          Icons.people_outline_rounded,
                          size: 26,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Hubungan wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin Pasien',
                        prefixIcon: Icon(Icons.wc_rounded, size: 26),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Lahir Pasien',
                          prefixIcon: Icon(
                            Icons.calendar_month_rounded,
                            size: 26,
                          ),
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
                    const SizedBox(height: AppSpacing.xl),
                    GeriatricPrimaryButton(
                      label: 'Simpan & Masuk ke Dasbor',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: isLoading,
                      onPressed: _onSubmit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
