import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_assets.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';

/// Brand mark: logo image + optional "KIVU" wordmark and tagline.
class KivuLogo extends StatelessWidget {
  const KivuLogo({
    super.key,
    this.showWordmark = true,
    this.showTagline = false,
    this.iconSize = 28,
    this.fontSize = 20,
  });

  /// When false, shows only the logo image (e.g. compact headers).
  final bool showWordmark;
  final bool showTagline;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.logo,
              height: iconSize,
              width: iconSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            if (showWordmark) ...[
              const SizedBox(width: 6),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            AppStrings.tagline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
          ),
        ],
      ],
    );
  }
}
