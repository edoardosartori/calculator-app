import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calc_app/features/calculator_app/presentation/state/calculator_controller.dart';

Future<CalculatorController> _controller() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return CalculatorController(prefs);
}

void main() {
  test('digit after confirmed result starts a new calculation', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.evaluate();
    expect(c.value.result, '5');

    c.appendToken('3');
    expect(c.value.expression, '3');
    expect(c.value.isResultConfirmed, isFalse);
  });

  test('operator after confirmed result continues from the result', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.evaluate();

    c.appendToken('×');
    expect(c.value.expression, '5×');
  });

  test('factorial applies to the confirmed result', () async {
    final c = await _controller();
    c.appendToken('3');
    c.evaluate();
    c.appendToken('!');
    expect(c.value.expression, '3!');
    expect(c.value.result, '6');
  });

  test('function key after confirmed result starts a new expression', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.evaluate();

    c.appendToken('sin(');
    expect(c.value.expression, 'sin(');
  });

  test('1/x after confirmed result wraps the result', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.evaluate();

    c.appendToken('1/');
    expect(c.value.expression, '1/(5)');
    expect(c.value.result, '0.2');
  });

  test('e^x after confirmed result wraps the result', () async {
    final c = await _controller();
    c.appendToken('5');
    c.evaluate();

    c.appendToken('e^');
    expect(c.value.expression, 'e^(5)');
  });

  test('1/x while editing wraps the whole expression', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.appendToken('1/');
    expect(c.value.expression, '1/(2+3)');
    expect(c.value.result, '0.2');
  });

  test('evaluate closes missing parentheses and confirms the result', () async {
    final c = await _controller();
    c.appendToken('sin(');
    c.appendToken('30');
    c.evaluate();

    expect(c.value.expression, 'sin(30)');
    expect(c.value.result, '0.5');
    expect(c.value.isResultConfirmed, isTrue);
  });

  test('live preview closes missing parentheses without mutating expression',
      () async {
    final c = await _controller();
    c.appendToken('sin(');
    c.appendToken('30');

    expect(c.value.expression, 'sin(30');
    expect(c.value.result, '0.5');
  });

  test('morphing key follows the innermost open function', () async {
    final c = await _controller();
    c.appendToken('tan(');
    expect(c.value.openParenKey, 'tan');

    c.appendToken('cos(');
    expect(c.value.openParenKey, 'cos');

    c.appendToken(')');
    expect(c.value.openParenKey, 'tan');

    c.appendToken(')');
    expect(c.value.openParenKey, isNull);
  });

  test('right parenthesis is ignored when parentheses are balanced', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.appendToken(')');

    expect(c.value.expression, '2+3');
  });

  test('inverse trigonometric functions use the inverse, not sin (DEG)',
      () async {
    final c = await _controller();
    c.appendToken('sin⁻¹(');
    c.appendToken('0.5');
    expect(c.value.result, '30');

    c.clear();
    c.appendToken('tan⁻¹(');
    c.appendToken('1');
    expect(c.value.result, '45');
  });

  test('error messages are in English', () async {
    final c = await _controller();
    c.appendToken('1');
    c.appendToken('÷');
    c.appendToken('0');
    c.evaluate();

    expect(c.value.errorMessage, 'Division by zero is not allowed');
  });

  test('backspace after a confirmed result resumes editing', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('+');
    c.appendToken('3');
    c.evaluate();

    c.deleteLastChar();
    expect(c.value.expression, '2+');
    expect(c.value.isResultConfirmed, isFalse);
  });

  test('decimal precision: 0.1+0.2 shows 0.3', () async {
    final c = await _controller();
    c.appendToken('0.1');
    c.appendToken('+');
    c.appendToken('0.2');
    expect(c.value.result, '0.3');
  });

  test('power is right-associative', () async {
    final c = await _controller();
    c.appendToken('2');
    c.appendToken('^');
    c.appendToken('3');
    c.appendToken('^');
    c.appendToken('2');
    expect(c.value.result, '512');
  });

  test('continuing from a scientific-notation result expands it', () async {
    final c = await _controller();
    c.appendToken('1000000');
    c.appendToken('×');
    c.appendToken('1000000');
    c.evaluate();
    expect(c.value.result, '1e+12');

    c.appendToken('×');
    expect(c.value.expression, '1000000000000×');
  });
}
