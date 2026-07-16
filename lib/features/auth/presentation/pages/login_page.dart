import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/widgets/placeholder_page.dart';

/// Placeholder login screen — Duke will implement the full UI + Firebase Auth.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Login',
      subtitle: 'Auth module — Duke',
      actionLabel: 'Continue',
      onAction: () => context.push(AppRoutes.otp),
    );
  }
}
