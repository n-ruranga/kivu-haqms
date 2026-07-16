import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/core/widgets/placeholder_page.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';

/// Placeholder OTP screen — Duke will implement SMS verification.
/// On success, call [AuthCubit.completeDemoLogin] (or real Firebase methods).
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Verify OTP',
      subtitle: 'Auth module — Duke',
      actionLabel: 'Verify & Login',
      onAction: () => context.read<AuthCubit>().completeDemoLogin(),
    );
  }
}
