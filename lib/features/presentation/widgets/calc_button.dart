import 'package:flutter/material.dart';

import '../../../../core/theme/fusion_theme_extension.dart';

import 'package:flutter/services.dart';

enum ButtonCategory { number, operator, action, active }

class CalcButton extends StatefulWidget {
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
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _isPressed = false;

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

    if (_isPressed) {
      backgroundColor = bluePrimary;
      textColor = theme.colorScheme.onPrimary;
      border = null;
    } else {
      switch (widget.category) {
        case ButtonCategory.number:
          backgroundColor = surfaceColor;
          textColor = textPrimary;
          border = Border.all(color: borderColor, width: 1);
          break;
        case ButtonCategory.operator:
        case ButtonCategory.action:
          backgroundColor = surfaceVariant;
          textColor = bluePrimary;
          border = Border.all(color: borderColor, width: 1);
          break;
        case ButtonCategory.active:
          backgroundColor = cyanActive;
          textColor = fusionTheme?.stateOnActive ?? const Color(0xFF07070F);
          border = null;
          break;
      }
      if (widget.label == ')') {
        textColor = fusionTheme?.characterSymbol ?? theme.colorScheme.tertiary;
      }
    }

    return Semantics(
      button: true,
      label: widget.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              if (widget.category == ButtonCategory.active) {
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.lightImpact();
              }
              widget.onTap();
            },
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            highlightColor: bluePrimary.withValues(alpha: 0.3),
            splashColor: bluePrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              alignment: Alignment.center,
              child: Text(
                widget.label,
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
      ),
    );
  }
}
