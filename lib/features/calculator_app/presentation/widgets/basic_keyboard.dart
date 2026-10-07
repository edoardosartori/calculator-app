import 'package:flutter/material.dart';

import 'calc_button.dart';

class BasicKeyboard extends StatelessWidget {
  const BasicKeyboard({
    super.key,
    required this.onToken,
    required this.onClear,
    required this.onDelete,
    required this.onEvaluate,
  });

  final ValueChanged<String> onToken;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onEvaluate;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.15,
      children: [
        // Row 1
        CalcButton(label: 'C', onTap: onClear, category: ButtonCategory.action),
        CalcButton(
            label: '√',
            onTap: () => onToken('√('),
            category: ButtonCategory.action),
        CalcButton(
            label: '%',
            onTap: () => onToken('%'),
            category: ButtonCategory.action),
        CalcButton(
            label: '÷',
            onTap: () => onToken('÷'),
            category: ButtonCategory.operator),

        // Row 2
        CalcButton(label: '7', onTap: () => onToken('7')),
        CalcButton(label: '8', onTap: () => onToken('8')),
        CalcButton(label: '9', onTap: () => onToken('9')),
        CalcButton(
            label: '×',
            onTap: () => onToken('×'),
            category: ButtonCategory.operator),

        // Row 3
        CalcButton(label: '4', onTap: () => onToken('4')),
        CalcButton(label: '5', onTap: () => onToken('5')),
        CalcButton(label: '6', onTap: () => onToken('6')),
        CalcButton(
            label: '−',
            onTap: () => onToken('−'),
            category: ButtonCategory.operator),

        // Row 4
        CalcButton(label: '1', onTap: () => onToken('1')),
        CalcButton(label: '2', onTap: () => onToken('2')),
        CalcButton(label: '3', onTap: () => onToken('3')),
        CalcButton(
            label: '+',
            onTap: () => onToken('+'),
            category: ButtonCategory.operator),

        // Row 5
        CalcButton(
            label: '⌫', onTap: onDelete, category: ButtonCategory.action),
        CalcButton(label: '0', onTap: () => onToken('0')),
        CalcButton(label: '.', onTap: () => onToken('.')),
        CalcButton(
            label: '=', onTap: onEvaluate, category: ButtonCategory.active),
      ],
    );
  }
}
