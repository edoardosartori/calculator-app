import 'package:flutter_test/flutter_test.dart';

import 'package:calc_app/features/calculator_app/domain/tokenizer.dart';

void main() {
  test('sin⁻¹ is tokenized as the inverse function, not sin', () {
    final tokens = Tokenizer.tokenize('sin⁻¹(0.5)');
    expect(
      tokens.map((t) => t.value).toList(),
      ['sin⁻¹', '(', '0.5', ')'],
    );
  });

  test('asin is a single function token', () {
    final tokens = Tokenizer.tokenize('asin(0.5)');
    expect(tokens.first.value, 'asin');
  });

  test('implicit multiplication between number and constant', () {
    final tokens = Tokenizer.tokenize('2π');
    expect(tokens.map((t) => t.value).toList(), ['2', '×', 'π']);
  });
}
