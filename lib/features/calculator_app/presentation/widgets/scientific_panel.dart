import 'package:flutter/material.dart';

import '../../../../core/theme/fusion_theme_extension.dart';
import 'calc_button.dart';

class ScientificPanel extends StatelessWidget {
  const ScientificPanel({
    super.key,
    required this.onToken,
    required this.isOpen,
    required this.onToggle,
  });

  final ValueChanged<String> onToken;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fusionTheme = theme.extension<FusionThemeExtension>();
    final Color textSecondary = theme.colorScheme.onSurfaceVariant;
    final Color borderColor = fusionTheme?.border ?? theme.colorScheme.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
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
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.3,
              children: [
                // Row 1
                CalcButton(
                    label: 'sin',
                    onTap: () => onToken('sin('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'cos',
                    onTap: () => onToken('cos('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'tan',
                    onTap: () => onToken('tan('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'ln',
                    onTap: () => onToken('ln('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'log',
                    onTap: () => onToken('log('),
                    category: ButtonCategory.action),

                // Row 2
                CalcButton(
                    label: 'sin⁻¹',
                    onTap: () => onToken('sin⁻¹('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'cos⁻¹',
                    onTap: () => onToken('cos⁻¹('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'tan⁻¹',
                    onTap: () => onToken('tan⁻¹('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'x²',
                    onTap: () => onToken('^2'),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'xʸ',
                    onTap: () => onToken('^'),
                    category: ButtonCategory.action),

                // Row 3
                CalcButton(
                    label: '1/x',
                    onTap: () => onToken('1/'),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'n!',
                    onTap: () => onToken('!'),
                    category: ButtonCategory.action),
                CalcButton(
                    label: '|x|',
                    onTap: () => onToken('abs('),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'π',
                    onTap: () => onToken('π'),
                    category: ButtonCategory.action),
                CalcButton(
                    label: 'eˣ',
                    onTap: () => onToken('e^'),
                    category: ButtonCategory.action),
              ],
            ),
          ),
      ],
    );
  }
}
