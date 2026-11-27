import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/caregiver/presentation/pages/caregiver_dashboard_page.dart';
import '../../features/caregiver/presentation/pages/caregiver_profile_page.dart';
import '../../features/patient/domain/models/patient_model.dart';
import '../../features/patient/presentation/pages/patient_form_page.dart';
import '../../features/patient/presentation/pages/patient_home_page.dart';
import '../../features/exercise/presentation/pages/exercise_page.dart';
import '../../features/history/presentation/pages/history_page.dart';

/// Router Fase 1: splash, auth, complete profile, dan dashboard sementara.
/// Rute pasien/latihan/riwayat ditambahkan pada fase berikutnya.
class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  static const _publicRoutes = {'/login', '/register', '/forgot-password'};

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: _redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (_, _) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: '/caregiver/dashboard',
        builder: (_, _) => const CaregiverDashboardPage(),
      ),
      GoRoute(
        path: '/caregiver/profile',
        builder: (_, _) => const CaregiverProfilePage(),
      ),
      GoRoute(
        path: '/patient/form',
        builder: (_, state) => PatientFormPage(
          initialPatient: state.extra is PatientModel
              ? state.extra as PatientModel
              : null,
        ),
      ),
      GoRoute(
        path: '/patient/home',
        builder: (_, _) => const PatientHomePage(),
      ),
      GoRoute(
        path: '/patient/exercise',
        builder: (_, _) => const ExercisePage(),
      ),
      GoRoute(path: '/history', builder: (_, _) => const HistoryPage()),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState routerState) {
    final auth = _authBloc.state;
    final loc = routerState.matchedLocation;

    switch (auth.status) {
      case AuthStatus.initial:
        return loc == '/splash' ? null : '/splash';
      case AuthStatus.loading:
        // Loading saat login/register/simpan profil: tetap di halaman sekarang.
        return null;
      case AuthStatus.authenticated:
        if (loc == '/splash' || _publicRoutes.contains(loc)) {
          return '/caregiver/dashboard';
        }
        if (loc == '/complete-profile') return '/caregiver/dashboard';
        return null;
      case AuthStatus.needsProfileCompletion:
        return loc == '/complete-profile' ? null : '/complete-profile';
      case AuthStatus.failure:
        // Gagal saat sudah login (mis. simpan profil): tetap di halaman itu.
        if (auth.caregiver != null) return null;
        return _publicRoutes.contains(loc) ? null : '/login';
      case AuthStatus.unauthenticated:
      case AuthStatus.passwordResetSent:
        return _publicRoutes.contains(loc) ? null : '/login';
    }
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
