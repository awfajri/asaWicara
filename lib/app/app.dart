import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/patient/presentation/cubit/patient_cubit.dart';
import 'di/app_dependencies.dart';
import 'router/app_router.dart';

class AsaWicaraApp extends StatefulWidget {
  const AsaWicaraApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AsaWicaraApp> createState() => _AsaWicaraAppState();
}

class _AsaWicaraAppState extends State<AsaWicaraApp> {
  late final AuthBloc _authBloc;
  late final PatientCubit _patientCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authRepository: widget.dependencies.authRepository,
      patientRepository: widget.dependencies.patientRepository,
    )..add(const AuthCheckRequested());
    _patientCubit = PatientCubit(
      patientRepository: widget.dependencies.patientRepository,
    );
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _patientCubit.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<PatientCubit>.value(value: _patientCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.caregiver?.id != current.caregiver?.id,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated &&
              state.caregiver != null) {
            _patientCubit.loadPatients(state.caregiver!.id);
          } else if (state.status == AuthStatus.unauthenticated) {
            _patientCubit.reset();
          }
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _appRouter.router,
          locale: const Locale('id', 'ID'),
          supportedLocales: const [Locale('id', 'ID')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
