import 'package:flutter/material.dart';

import '../../../../core/theme/fusion_theme_extension.dart';

enum ButtonCategory { number, operator, action, active }

class CalcButton extends StatelessWidget {
  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.category = ButtonCategory.number,
  });

  final String label;
  final VoidCallback onTap;
  final ButtonCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fusionTheme = theme.extension<FusionThemeExtension>();

    final Color surfaceColor = theme.colorScheme.surface;
    final Color surfaceVariant = fusionTheme?.surfaceVariant ??
        theme.colorScheme.surfaceContainerHighest;
    final Color borderColor = fusionTheme?.border ?? theme.colorScheme.outline;
    final Color textPrimary = theme.colorScheme.onSurface;
    final Color bluePrimary = theme.colorScheme.primary;
    final Color cyanActive =
        fusionTheme?.stateActive ?? theme.colorScheme.secondary;

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (category) {
      case ButtonCategory.number:
        backgroundColor = surfaceColor;
        textColor = textPrimary;
        border = Border.all(color: borderColor, width: 1);
        break;
      case ButtonCategory.operator:
        backgroundColor = surfaceVariant;
        textColor = bluePrimary;
        border = Border.all(color: borderColor, width: 1);
        break;
      case ButtonCategory.action:
        backgroundColor = surfaceVariant;
        textColor = textPrimary;
        border = Border.all(color: borderColor, width: 1);
        break;
      case ButtonCategory.active:
        backgroundColor = cyanActive;
        textColor = fusionTheme?.stateOnActive ?? const Color(0xFF07070F);
        border = null;
        break;
    }

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
