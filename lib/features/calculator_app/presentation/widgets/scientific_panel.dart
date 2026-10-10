import 'package:flutter/material.dart';

import '../../../../core/theme/fusion_motion.dart';
import '../../../../core/theme/fusion_theme_extension.dart';
import 'calc_button.dart';

/// Key label -> token appended to the expression.
/// Insertion order is the phone order (5 columns).
const Map<String, String> _scientificKeyTokens = {
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

/// Tablet order: 3 columns x 5 rows. Same keys and tokens as the phone.
const List<List<String>> _tabletKeyRows = [
  ['sin', 'cos', 'tan'],
  ['sin⁻¹', 'cos⁻¹', 'tan⁻¹'],
  ['ln', 'log', 'x²'],
  ['xʸ', '1/x', 'n!'],
  ['|x|', 'π', 'eˣ'],
];

Widget _buildScientificKey({
  required String label,
  required String? openParenKey,
  required ValueChanged<String> onToken,
}) {
  final bool isMorphed = openParenKey == label;

  return CalcButton(
    label: isMorphed ? ')' : label,
    onTap: () => onToken(isMorphed ? ')' : _scientificKeyTokens[label]!),
    category: ButtonCategory.action,
  );
}

/// Drag handle + "fx" label that opens and closes the scientific keys.
/// Takes the full width it is given.
class ScientificToggle extends StatelessWidget {
  const ScientificToggle({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

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
      ],
    );
  }
}

/// Phone layout: toggle on top, 5-column grid below when open.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScientificToggle(isOpen: isOpen, onToggle: onToggle),
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
                for (final String label in _scientificKeyTokens.keys)
                  _buildScientificKey(
                    label: label,
                    openParenKey: openParenKey,
                    onToken: onToken,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tablet layout: 3 columns x 5 rows that fill the height it is given.
class ScientificKeypad extends StatelessWidget {
  const ScientificKeypad({
    super.key,
    required this.onToken,
    required this.openParenKey,
  });

  final ValueChanged<String> onToken;
  final String? openParenKey;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    assert(
      _tabletKeyRows
          .expand((row) => row)
          .every(_scientificKeyTokens.containsKey),
      'Every tablet key must exist in _scientificKeyTokens',
    );

    return Column(
      children: [
        for (int r = 0; r < _tabletKeyRows.length; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int c = 0; c < _tabletKeyRows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(
                    child: _buildScientificKey(
                      label: _tabletKeyRows[r][c],
                      openParenKey: openParenKey,
                      onToken: onToken,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
