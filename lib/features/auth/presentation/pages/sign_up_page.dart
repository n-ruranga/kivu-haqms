import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/widgets/placeholder_page.dart';

/// Placeholder sign-up screen — Duke will implement email/password + Google sign-in.
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Sign Up',
      subtitle: 'Auth module — Duke',
    );
  }
}
