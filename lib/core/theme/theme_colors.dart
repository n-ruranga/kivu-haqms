import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';

extension ThemeColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  Color get cardSurface => colors.surface;

  Color get cardBorder => Theme.of(this).dividerColor;

  Color get mutedText => colors.onSurfaceVariant;

  Color get primaryText => colors.onSurface;

  Color get primaryTintBackground => colors.brightness == Brightness.dark
      ? colors.primary.withValues(alpha: 0.18)
      : AppColors.primaryLight;

  Color get successTintBackground => colors.brightness == Brightness.dark
      ? AppColors.success.withValues(alpha: 0.18)
      : AppColors.successLight;

  BoxDecoration cardDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: cardSurface,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: cardBorder),
    );
  }
}
