import 'package:flutter/material.dart';

class ExpressionFormatter {
  static TextSpan buildTextSpan({
    required String expression,
    required TextStyle defaultStyle,
    required Color amberColor,
  }) {
    if (expression.isEmpty) {
      return TextSpan(text: '', style: defaultStyle);
    }

    final List<InlineSpan> spans = [];
    final RegExp regex = RegExp(
      r'([+\−\-×\*÷\/\^\%\!\(\)]|sin⁻¹|cos⁻¹|tan⁻¹|asin⁻¹|acos⁻¹|atan⁻¹|sin|cos|tan|asin|acos|atan|ln|log|√|sqrt|abs)',
    );

    int lastIndex = 0;
    for (final Match match in regex.allMatches(expression)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: expression.substring(lastIndex, match.start),
            style: defaultStyle,
          ),
        );
      }

      final String matchedText = match.group(0)!;
      spans.add(
        TextSpan(
          text: matchedText,
          style: defaultStyle.copyWith(color: amberColor),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < expression.length) {
      spans.add(
        TextSpan(
          text: expression.substring(lastIndex),
          style: defaultStyle,
        ),
      );
    }

    return TextSpan(children: spans);
  }
}
