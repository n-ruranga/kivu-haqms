import 'package:flutter/material.dart';

/// KIVU brand colors matching the Figma prototype and logo.
abstract final class AppColors {
  /// Matches `assets/images/kivu-logo.png` blue.
  static const Color primary = Color(0xFF2E66F6);
  static const Color primaryDark = Color(0xFF1E4FD6);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color primaryGradientEnd = Color(0xFF1A3FB8);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color busy = Color(0xFF9CA3AF);
  static const Color star = Color(0xFFFBBF24);
}
