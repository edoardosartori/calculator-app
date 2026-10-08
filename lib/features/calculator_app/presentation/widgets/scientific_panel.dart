import 'package:flutter/material.dart';

import '../../../../core/theme/fusion_motion.dart';
import '../../../../core/theme/fusion_theme_extension.dart';
import 'calc_button.dart';

class ScientificPanel extends StatelessWidget {
  const ScientificPanel({
    super.key,
    required this.onToken,
    required this.isOpen,
    required this.onToggle,
    required this.openParenKey,
  });

  final ValueChanged<String> onToken;
  final bool isOpen;
  final VoidCallback onToggle;

  /// Label of the key that currently shows ')' because its parenthesis
  /// is still open (morphing key). Null when all parentheses are closed.
  final String? openParenKey;

  static const Map<String, String> _keyTokens = {
    'sin': 'sin(',
    'cos': 'cos(',
    'tan': 'tan(',
    'ln': 'ln(',
    'log': 'log(',
    'sin⁻¹': 'sin⁻¹(',
    'cos⁻¹': 'cos⁻¹(',
    'tan⁻¹': 'tan⁻¹(',
    'x²': '^2',
    'xʸ': '^',
    '1/x': '1/',
    'n!': '!',
    '|x|': 'abs(',
    'π': 'π',
    'eˣ': 'e^',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fusionTheme = theme.extension<FusionThemeExtension>();
    final Color textSecondary = theme.colorScheme.onSurfaceVariant;
    final Color borderColor = fusionTheme?.border ?? theme.colorScheme.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: 'Toggle scientific keyboard',
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'fx',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ),
        if (isOpen)
          AnimatedContainer(
            duration: FusionMotion.normal,
            curve: FusionMotion.curve,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.3,
              children: [
                for (final String label in _keyTokens.keys) _buildKey(label),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKey(String label) {
    final bool isMorphed = openParenKey == label;

    return CalcButton(
      label: isMorphed ? ')' : label,
      onTap: () => onToken(isMorphed ? ')' : _keyTokens[label]!),
      category: ButtonCategory.action,
    );
  }
}
