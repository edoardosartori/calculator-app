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

  /// Key labels shown for each function that opens a parenthesis.
  static const Map<String, String> _functionKeyLabels = {
    'sin⁻¹': 'sin⁻¹',
    'cos⁻¹': 'cos⁻¹',
    'tan⁻¹': 'tan⁻¹',
    'asin⁻¹': 'asin⁻¹',
    'acos⁻¹': 'acos⁻¹',
    'atan⁻¹': 'atan⁻¹',
    'asin': 'asin',
    'acos': 'acos',
    'atan': 'atan',
    'sin': 'sin',
    'cos': 'cos',
    'tan': 'tan',
    'ln': 'ln',
    'log': 'log',
    'sqrt': 'sqrt',
    'abs': '|x|',
    '√': '√',
  };

  /// Function names, longest first so that 'sin⁻¹' is matched before 'sin'.
  static const List<String> _functionNames = [
    'asin⁻¹',
    'acos⁻¹',
    'atan⁻¹',
    'sin⁻¹',
    'cos⁻¹',
    'tan⁻¹',
    'asin',
    'acos',
    'atan',
    'sin',
    'cos',
    'tan',
    'ln',
    'log',
    'sqrt',
    'abs',
    '√',
  ];

  /// Binary operators as typed by the keyboard ('−' is U+2212, like the key).
  static const Set<String> _binaryOperators = {'+', '−', '×', '÷', '^'};

  /// Postfix tokens: they only make sense right after an operand.
  static const Set<String> _postfixTokens = {'%', '!', '^2'};

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
    final String newExpression = value.isResultConfirmed
        ? _startFromResult(token)
        : _appendToEditing(token);

    if (newExpression == value.expression) {
      // Nothing to add (e.g. ')' with no parenthesis to close, or a token
      // rejected by _isTokenAllowed).
      return;
    }

    _updateExpression(newExpression);
  }

  void clear() {
    value = value.copyWith(
      expression: '',
      result: '0',
      clearError: true,
      isResultConfirmed: false,
      openParenKey: null,
    );
  }

  void deleteLastChar() {
    if (value.expression.isEmpty) return;

    _updateExpression(
      value.expression.substring(0, value.expression.length - 1),
    );
  }

  void evaluate() {
    if (value.expression.isEmpty) return;

    // Safety net: close any missing ')' before evaluating.
    final String closed = _closeParens(value.expression);

    try {
      final tokens = Tokenizer.tokenize(closed);
      final ast = Parser(tokens).parse();
      final double evalResult = Evaluator.evaluate(ast, value.angleUnit);
      final String formatted = Evaluator.formatResult(evalResult);

      value = value.copyWith(
        expression: closed,
        result: formatted,
        clearError: true,
        isResultConfirmed: true,
        openParenKey: null,
      );
    } on UnsupportedError catch (e) {
      value = value.copyWith(
        errorMessage: e.message?.toString() ?? 'Error',
      );
    } on FormatException {
      value = value.copyWith(errorMessage: 'Invalid expression');
    } catch (_) {
      value = value.copyWith(errorMessage: 'Error');
    }
  }

  // ---------------------------------------------------------------------
  // Input handling
  // ---------------------------------------------------------------------

  /// Builds the new expression when '=' has just confirmed a result.
  String _startFromResult(String token) {
    if (token == ')') {
      // After a confirmed result all parentheses are closed.
      return value.expression;
    }

    if (!_resultIsUsable) {
      // After an error every input starts a new calculation, subject to the
      // same checks as an empty expression.
      return _isTokenAllowed('', token) ? token : value.expression;
    }

    if (token == '1/' || token == 'e^') {
      return '$token($_expandedResult)';
    }

    if (token == '.') {
      return '0.';
    }

    final bool isDigit = token.length == 1 &&
        token.compareTo('0') >= 0 &&
        token.compareTo('9') <= 0;
    final bool isConstant = token == 'π' || token == 'e';
    final bool isOpener = token.endsWith('(');

    if (isDigit || isConstant || isOpener) {
      return token;
    }

    // Binary operators, '!' and '^2' continue from the result.
    return '$_expandedResult$token';
  }

  /// Builds the new expression while the user is still editing.
  String _appendToEditing(String token) {
    final String expression = value.expression;

    // Discard clearly invalid input; the key stays tappable but nothing is
    // added to the expression.
    if (!_isTokenAllowed(expression, token)) {
      return expression;
    }

    if (token == '1/' || token == 'e^') {
      // Wrap the whole current expression.
      final String inner = _closeParens(expression);
      return inner.isEmpty ? '$token(' : '$token($inner)';
    }

    if (token == ')' && _openParenCount(expression) <= 0) {
      return expression;
    }

    return '$expression$token';
  }

  void _updateExpression(String expression) {
    value = value.copyWith(
      expression: expression,
      clearError: true,
      isResultConfirmed: false,
      openParenKey: _deriveOpenParenKey(expression),
    );
    _evaluateCurrentExpression();
  }

  bool get _resultIsUsable =>
      value.errorMessage == null &&
      value.result.isNotEmpty &&
      value.result != 'Error';

  /// Results in scientific notation (e.g. '1e+12') cannot be tokenized
  /// back as plain numbers, so expand them to a full decimal string.
  String get _expandedResult {
    final String result = value.result;
    if (!result.contains('e')) return result;

    final double? parsed = double.tryParse(result);
    if (parsed == null) return result;

    return parsed.abs() < 1.0
        ? parsed.toStringAsFixed(15)
        : parsed.toStringAsFixed(0);
  }

  // ---------------------------------------------------------------------
  // Input checks
  // ---------------------------------------------------------------------

  /// Returns true when [token] may follow [expression]. Only clear-cut
  /// mistakes are blocked; anything else is left to the parser, which
  /// reports "Invalid expression" on '='.
  static bool _isTokenAllowed(String expression, String token) {
    final String last =
        expression.isEmpty ? '' : expression[expression.length - 1];
    final bool atStart = last.isEmpty || last == '(';
    final bool afterOperator = _binaryOperators.contains(last);

    // Unary minus (negative numbers): blocked only right after '+' or '−'.
    if (token == '−') {
      return last != '+' && last != '−';
    }

    // Other binary operators, postfix tokens and ')' need an operand
    // right before them.
    if (_binaryOperators.contains(token) ||
        _postfixTokens.contains(token) ||
        token == ')') {
      return !atStart && !afterOperator;
    }

    // '1/' and 'e^' wrap the whole expression, which must be complete.
    if (token == '1/' || token == 'e^') {
      return expression.isEmpty || !(afterOperator || last == '(');
    }

    // At most one decimal point per number.
    if (token == '.') {
      return !_currentNumber(expression).contains('.');
    }

    return true;
  }

  /// The digits and dots at the end of [expression] (the number being typed).
  static String _currentNumber(String expression) {
    int start = expression.length;
    while (start > 0 && _isDigitOrDot(expression[start - 1])) {
      start--;
    }
    return expression.substring(start);
  }

  static bool _isDigitOrDot(String char) =>
      char == '.' || (char.compareTo('0') >= 0 && char.compareTo('9') <= 0);

  // ---------------------------------------------------------------------
  // Parentheses helpers
  // ---------------------------------------------------------------------

  static int _openParenCount(String expression) {
    int count = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') count++;
      if (expression[i] == ')') count--;
    }
    return count;
  }

  static String _closeParens(String expression) {
    final int unclosed = _openParenCount(expression);
    if (unclosed <= 0) return expression;
    return '$expression${')' * unclosed}';
  }

  /// Returns the key label whose parenthesis is the innermost still-open
  /// function parenthesis, or null. Derived from the expression only, so
  /// it stays consistent after deletions too.
  static String? _deriveOpenParenKey(String expression) {
    final List<String?> stack = [];
    int i = 0;

    while (i < expression.length) {
      final String char = expression[i];

      if (char == '(') {
        final String prefix = expression.substring(0, i);
        String? label;
        for (final String name in _functionNames) {
          if (prefix.endsWith(name)) {
            label = _functionKeyLabels[name];
            break;
          }
        }
        stack.add(label);
        i++;
        continue;
      }

      if (char == ')') {
        if (stack.isNotEmpty) stack.removeLast();
        i++;
        continue;
      }

      i++;
    }

    for (int j = stack.length - 1; j >= 0; j--) {
      final String? label = stack[j];
      if (label != null) return label;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Live preview
  // ---------------------------------------------------------------------

  void _evaluateCurrentExpression() {
    if (value.expression.trim().isEmpty) {
      value = value.copyWith(result: '0', clearError: true);
      return;
    }

    try {
      final String closed = _closeParens(value.expression);
      final tokens = Tokenizer.tokenize(closed);
      final ast = Parser(tokens).parse();
      final double evalResult = Evaluator.evaluate(ast, value.angleUnit);
      final String formatted = Evaluator.formatResult(evalResult);

      value = value.copyWith(result: formatted, clearError: true);
    } catch (_) {
      // Keep the previous result while the expression is incomplete.
    }
  }
}
