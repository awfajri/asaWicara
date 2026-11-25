import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/geriatric_info_banner.dart';
import '../../../../core/widgets/geriatric_primary_button.dart';
import '../../../../core/widgets/geriatric_secondary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk Akun Pendamping')),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.needsProfileCompletion) {
              context.go('/complete-profile');
            } else if (state.status == AuthStatus.authenticated) {
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
                      'Selamat Datang di ${AppConstants.appName}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppConstants.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const GeriatricInfoBanner(
                      title: '1 Perangkat Dipakai Bergantian',
                      message:
                          'Pendamping masuk menggunakan akun ini untuk mengelola profil lansia dan mengaktifkan Mode Pasien saat latihan.',
                      icon: Icons.family_restroom_rounded,
                    ),
                    if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      GeriatricInfoBanner(
                        title: 'Gagal Masuk',
                        message: state.errorMessage!,
                        icon: Icons.warning_amber_rounded,
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
                        labelText: 'Email Pendamping',
                        prefixIcon: Icon(Icons.email_outlined, size: 26),
                      ),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.isEmpty || !text.contains('@')) {
                          return 'Masukkan alamat email yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        prefixIcon: const Icon(Icons.lock_outline, size: 26),
                        suffixIcon: IconButton(
                          iconSize: 28,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (v) {
                        if ((v ?? '').length < 6) {
                          return 'Kata sandi minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push('/forgot-password'),
                        child: const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GeriatricPrimaryButton(
                      label: 'Masuk Sekarang',
                      icon: Icons.login_rounded,
                      isLoading: isLoading,
                      onPressed: _onLogin,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GeriatricSecondaryButton(
                      label: 'Belum Punya Akun? Daftar',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: isLoading
                          ? null
                          : () => context.go('/register'),
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
