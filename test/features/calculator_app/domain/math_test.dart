import 'package:flutter_test/flutter_test.dart';
import 'package:calc_app/features/calculator_app/domain/tokenizer.dart';
import 'package:calc_app/features/calculator_app/domain/parser.dart';
import 'package:calc_app/features/calculator_app/domain/evaluator.dart';

import 'dart:math' as math;

double _eval(String expression, {AngleUnit angleUnit = AngleUnit.deg}) {
  final tokens = Tokenizer.tokenize(expression);
  final ast = Parser(tokens).parse();
  return Evaluator.evaluate(ast, angleUnit);
}

void main() {
  group('Inverse Trigonometric Functions', () {
    test('sin⁻¹ is tokenized as the inverse function, not as sin', () {
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

    test('evaluates inverse functions in DEG', () {
      expect(_eval('sin⁻¹(0.5)', angleUnit: AngleUnit.deg), closeTo(30, 1e-9));
      expect(_eval('cos⁻¹(0.5)', angleUnit: AngleUnit.deg), closeTo(60, 1e-9));
      expect(_eval('tan⁻¹(1)', angleUnit: AngleUnit.deg), closeTo(45, 1e-9));
    });

    test('evaluates inverse functions in RAD', () {
      expect(
        _eval('sin⁻¹(0.5)', angleUnit: AngleUnit.rad),
        closeTo(math.pi / 6, 1e-10),
      );
    });
  });

  group('Conventions', () {
    test('percent operator is modulo', () {
      // Documents the current convention: '%' is the modulo operator.
      expect(_eval('10 % 3'), equals(1));
    });
  });

  group('Tokenizer & Implicit Multiplication', () {
    test('inserts implicit multiplication between number and constant/paren',
        () {
      final tokens = Tokenizer.tokenize('2π + 3(4+5)');
      final values = tokens.map((t) => t.value).toList();
      expect(values,
          equals(['2', '×', 'π', '+', '3', '×', '(', '4', '+', '5', ')']));
    });
  });

  group('Parser & Precedence', () {
    test('handles right-associative power operator', () {
      // 2^3^2 deve essere interpretato come 2^(3^2) = 2^9 = 512
      final result = _eval('2^3^2');
      expect(result, equals(512));
    });

    test('handles standard operators precedence', () {
      final result = _eval('2 + 3 × 4');
      expect(result, equals(14));
    });
  });

  group('Evaluator & Precision', () {
    test('eliminates floating point errors (0.1 + 0.2)', () {
      final rawResult = _eval('0.1 + 0.2');
      final formatted = Evaluator.formatResult(rawResult);
      expect(formatted, equals('0.3'));
    });

    test('evaluates trig functions in DEG and RAD', () {
      expect(_eval('sin(30)', angleUnit: AngleUnit.deg), equals(0.5));
      expect(
          _eval('sin(π ÷ 6)', angleUnit: AngleUnit.rad), closeTo(0.5, 1e-10));
    });

    test('evaluates factorials correctly', () {
      expect(_eval('5!'), equals(120));
      expect(_eval('0!'), equals(1));
      expect(_eval('170!'), isA<double>());
    });

    test('throws exception on factorial overflow (>170)', () {
      expect(() => _eval('171!'), throwsA(isA<UnsupportedError>()));
    });

    test('throws exception on division by zero', () {
      expect(() => _eval('5 ÷ 0'), throwsA(isA<UnsupportedError>()));
    });

    test('throws exception on invalid domain (sqrt of negative)', () {
      expect(() => _eval('√(−4)'), throwsA(isA<UnsupportedError>()));
    });
  });
}
