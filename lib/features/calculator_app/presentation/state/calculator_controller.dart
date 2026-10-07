import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/evaluator.dart';
import '../../domain/parser.dart';
import '../../domain/tokenizer.dart';
import '../../models/calculator_state.dart';

class CalculatorController extends ValueNotifier<CalculatorState> {
  CalculatorController(this._preferences)
      : super(
          CalculatorState(
            expression: '',
            result: '0',
            angleUnit: _loadAngleUnit(_preferences),
          ),
        );

  final SharedPreferences _preferences;
  static const String _angleUnitKey = 'angle_unit';

  static AngleUnit _loadAngleUnit(SharedPreferences prefs) {
    final String? saved = prefs.getString(_angleUnitKey);
    return saved == 'rad' ? AngleUnit.rad : AngleUnit.deg;
  }

  void toggleAngleUnit() {
    final AngleUnit nextUnit =
        value.angleUnit == AngleUnit.deg ? AngleUnit.rad : AngleUnit.deg;
    value = value.copyWith(angleUnit: nextUnit);
    _preferences.setString(_angleUnitKey, nextUnit.name);
    _evaluateCurrentExpression();
  }

  void toggleScientificPanel() {
    value = value.copyWith(isScientificOpen: !value.isScientificOpen);
  }

  void appendToken(String token) {
    final String newExpression = value.expression + token;
    value = value.copyWith(expression: newExpression, clearError: true);
    _evaluateCurrentExpression();
  }

  void clear() {
    value = value.copyWith(expression: '', result: '0', clearError: true);
  }

  void deleteLastChar() {
    if (value.expression.isNotEmpty) {
      final String newExpression =
          value.expression.substring(0, value.expression.length - 1);
      value = value.copyWith(expression: newExpression, clearError: true);
      _evaluateCurrentExpression();
    }
  }

  void evaluate() {
    if (value.expression.isEmpty) return;

    try {
      final tokens = Tokenizer.tokenize(value.expression);
      final ast = Parser(tokens).parse();
      final double evalResult = Evaluator.evaluate(ast, value.angleUnit);
      final String formatted = Evaluator.formatResult(evalResult);

      value = value.copyWith(
        result: formatted,
        clearError: true,
      );
    } on UnsupportedError catch (e) {
      value = value.copyWith(errorMessage: e.message ?? 'Errore');
    } on FormatException {
      value = value.copyWith(errorMessage: 'Espressione non valida');
    } catch (_) {
      value = value.copyWith(errorMessage: 'Errore');
    }
  }

  void _evaluateCurrentExpression() {
    if (value.expression.trim().isEmpty) {
      value = value.copyWith(result: '0', clearError: true);
      return;
    }

    try {
      final tokens = Tokenizer.tokenize(value.expression);
      final ast = Parser(tokens).parse();
      final double evalResult = Evaluator.evaluate(ast, value.angleUnit);
      final String formatted = Evaluator.formatResult(evalResult);

      value = value.copyWith(result: formatted, clearError: true);
    } catch (_) {
      // Keep previous result or wait for expression completion
    }
  }
}
