import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/widgets/placeholder_page.dart';

/// Placeholder OTP screen — Duke will implement SMS verification.
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Verify OTP',
      subtitle: 'Auth module — Duke',
      actionLabel: 'Verify & Login',
      onAction: () => context.go(AppRoutes.home),
    );
  }
}
