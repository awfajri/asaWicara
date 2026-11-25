import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthForgotPasswordSubmitted(email: _emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Kata Sandi')),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
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
                      'Masukkan alamat email akun pendamping Anda untuk menerima tautan pengaturan ulang kata sandi.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.status == AuthStatus.passwordResetSent) ...[
                      const GeriatricInfoBanner(
                        title: 'Tautan Terkirim',
                        message:
                            'Silakan periksa kotak masuk email Anda dan ikuti tautan untuk membuat kata sandi baru.',
                        icon: Icons.mark_email_read_outlined,
                        backgroundColor: AppColors.successContainer,
                        iconColor: AppColors.success,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) ...[
                      GeriatricInfoBanner(
                        title: 'Gagal Mengirim',
                        message: state.errorMessage!,
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.dangerContainer,
                        iconColor: AppColors.danger,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Email Terdaftar',
                        prefixIcon: Icon(Icons.email_outlined, size: 26),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Masukkan alamat email yang valid.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GeriatricPrimaryButton(
                      label: 'Kirim Tautan Reset',
                      icon: Icons.send_rounded,
                      isLoading: isLoading,
                      onPressed: _onSubmit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Kembali ke Halaman Masuk',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
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
