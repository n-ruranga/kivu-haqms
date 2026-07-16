import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/router/app_router.dart';
import 'package:kivu_haqms/core/theme/app_theme.dart';
import 'package:kivu_haqms/features/auth/data/repositories/stub_auth_repository.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';

class KivuApp extends StatefulWidget {
  const KivuApp({super.key});

  @override
  State<KivuApp> createState() => _KivuAppState();
}

class _KivuAppState extends State<KivuApp> {
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Duke: swap StubAuthRepository for FirebaseAuthRepository.
    _authRepository = StubAuthRepository();
    _authCubit = AuthCubit(_authRepository);
    _router = AppRouter.create(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: _authRepository,
      child: BlocProvider<AuthCubit>.value(
        value: _authCubit,
        child: MaterialApp.router(
          title: 'KIVU',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
