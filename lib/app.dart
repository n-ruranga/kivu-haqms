import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/router/app_router.dart';
import 'package:kivu_haqms/core/theme/app_theme.dart';

class KivuApp extends StatelessWidget {
  const KivuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KIVU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
