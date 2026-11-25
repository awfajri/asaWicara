import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../../../../core/widgets/geriatric_secondary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreePrivacy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon setujui kebijakan privasi terlebih dahulu.'),
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthRegisterSubmitted(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Pendamping')),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.needsProfileCompletion) {
              context.go('/complete-profile');
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
                      'Langkah 1 dari 2: Buat Akun',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Setelah mendaftar, Anda akan melengkapi data pendamping dan menambahkan profil pasien lansia pertama.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      GeriatricInfoBanner(
                        title: 'Pendaftaran Gagal',
                        message: state.errorMessage!,
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.dangerContainer,
                        iconColor: AppColors.danger,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Email',
                        prefixIcon: Icon(Icons.email_outlined, size: 26),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Masukkan format email yang valid.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi (Min. 6 Karakter)',
                        prefixIcon: Icon(Icons.lock_outline, size: 26),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Kata sandi minimal 6 karakter.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Ulangi Kata Sandi',
                        prefixIcon: Icon(Icons.lock_reset_rounded, size: 26),
                      ),
                      validator: (v) => v != _passwordCtrl.text
                          ? 'Konfirmasi kata sandi tidak cocok.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _agreePrivacy,
                      onChanged: (val) =>
                          setState(() => _agreePrivacy = val ?? false),
                      title: Text(
                        'Saya memahami AsaWicara adalah alat pendamping latihan mandiri (bukan diagnosis medis) dan menyetujui penyimpanan rekaman privat.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GeriatricPrimaryButton(
                      label: 'Lanjut Lengkapi Profil',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: isLoading,
                      onPressed: _onRegister,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GeriatricSecondaryButton(
                      label: 'Sudah Punya Akun? Masuk',
                      icon: Icons.arrow_back_rounded,
                      onPressed: isLoading ? null : () => context.go('/login'),
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
