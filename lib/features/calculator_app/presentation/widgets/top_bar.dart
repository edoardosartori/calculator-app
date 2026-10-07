import 'package:flutter/material.dart';

import '../../../../core/theme/fusion_theme_extension.dart';
import '../../domain/evaluator.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.angleUnit,
    required this.onAngleUnitToggle,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final AngleUnit angleUnit;
  final VoidCallback onAngleUnitToggle;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fusionTheme = theme.extension<FusionThemeExtension>();

    final Color textPrimary = theme.colorScheme.onSurface;
    final Color surfaceVariant = fusionTheme?.surfaceVariant ??
        theme.colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // DEG / RAD Toggle Button
          Semantics(
            button: true,
            label: 'Current angle unit: ${angleUnit.name.toUpperCase()}',
            child: Material(
              color: surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onAngleUnitToggle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    angleUnit.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Theme Toggle Button
          Semantics(
            button: true,
            label: 'Toggle theme mode',
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              color: textPrimary,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: onThemeToggle,
            ),
          ),
        ],
      ),
    );
  }
}
