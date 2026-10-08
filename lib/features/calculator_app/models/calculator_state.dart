import '../domain/evaluator.dart';

class CalculatorState {
  const CalculatorState({
    required this.expression,
    required this.result,
    required this.angleUnit,
    this.errorMessage,
    this.isScientificOpen = false,
    this.isResultConfirmed = false,
    this.openParenKey,
  });

  final String expression;
  final String result;
  final AngleUnit angleUnit;
  final String? errorMessage;
  final bool isScientificOpen;

  /// True right after '=' confirmed the result; the next significant
  /// input either starts a new calculation or continues from the result.
  final bool isResultConfirmed;

  /// Label of the keyboard key whose parenthesis is still open and that
  /// therefore shows ')' (morphing key). Null when all parens are closed.
  final String? openParenKey;

  static const Object _unset = Object();

  CalculatorState copyWith({
    String? expression,
    String? result,
    AngleUnit? angleUnit,
    String? errorMessage,
    bool? isScientificOpen,
    bool? isResultConfirmed,
    Object? openParenKey = _unset,
    bool clearError = false,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      angleUnit: angleUnit ?? this.angleUnit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isScientificOpen: isScientificOpen ?? this.isScientificOpen,
      isResultConfirmed: isResultConfirmed ?? this.isResultConfirmed,
      openParenKey:
          openParenKey == _unset ? this.openParenKey : openParenKey as String?,
    );
  }
}
