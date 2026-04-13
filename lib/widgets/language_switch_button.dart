import 'package:flutter/material.dart';
import '../l10n/app_locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppLocaleController.of(context);
    final l10n = context.l10n;

    return TextButton.icon(
      onPressed: controller.toggle,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      icon: const Icon(Icons.language, size: 18),
      label: Text(l10n.language),
    );
  }
}
