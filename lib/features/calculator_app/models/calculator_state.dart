import '../domain/evaluator.dart';

class CalculatorState {
  const CalculatorState({
    required this.expression,
    required this.result,
    required this.angleUnit,
    this.errorMessage,
    this.isScientificOpen = false,
  });

  final String expression;
  final String result;
  final AngleUnit angleUnit;
  final String? errorMessage;
  final bool isScientificOpen;

  CalculatorState copyWith({
    String? expression,
    String? result,
    AngleUnit? angleUnit,
    String? errorMessage,
    bool? isScientificOpen,
    bool clearError = false,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      angleUnit: angleUnit ?? this.angleUnit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isScientificOpen: isScientificOpen ?? this.isScientificOpen,
    );
  }
}
