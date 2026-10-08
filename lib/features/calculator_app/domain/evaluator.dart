import 'dart:math' as math;
import 'parser.dart';

enum AngleUnit { deg, rad }

class Evaluator {
  static double evaluate(ExpressionNode node, AngleUnit angleUnit) {
    if (node is NumberNode) {
      return node.value;
    }

    if (node is ConstantNode) {
      return switch (node.name) {
        'π' => math.pi,
        'e' => math.e,
        _ => throw FormatException('Unknown constant: ${node.name}'),
      };
    }

    if (node is UnaryOpNode) {
      final double operand = evaluate(node.operand, angleUnit);
      if (node.operator == '-') return -operand;
      if (node.operator == '!') return _factorial(operand);
      throw FormatException('Unknown unary operator: ${node.operator}');
    }

    if (node is BinaryOpNode) {
      final double left = evaluate(node.left, angleUnit);
      final double right = evaluate(node.right, angleUnit);

      return switch (node.operator) {
        '+' => left + right,
        '-' || '−' => left - right,
        '*' || '×' => left * right,
        '/' || '÷' => right == 0
            ? throw UnsupportedError('Division by zero is not allowed')
            : left / right,
        '%' => left % right,
        '^' => math.pow(left, right).toDouble(),
        _ => throw FormatException('Unknown operator: ${node.operator}'),
      };
    }

    if (node is FunctionNode) {
      final double arg = evaluate(node.argument, angleUnit);
      return _evalFunction(node.name, arg, angleUnit);
    }

    throw FormatException('Unknown node type');
  }

  static double _evalFunction(String name, double arg, AngleUnit angleUnit) {
    final double radArg =
        angleUnit == AngleUnit.deg ? arg * (math.pi / 180.0) : arg;

    switch (name) {
      case 'sin':
        return _cleanTrigResult(math.sin(radArg), arg, angleUnit, true);
      case 'cos':
        return _cleanTrigResult(math.cos(radArg), arg, angleUnit, false);
      case 'tan':
        final double cosVal = math.cos(radArg);
        if (cosVal.abs() < 1e-15) {
          throw UnsupportedError('Invalid domain');
        }
        return _cleanTrigResult(math.tan(radArg), arg, angleUnit, false);
      case 'asin':
      case 'asin⁻¹':
      case 'sin⁻¹':
        if (arg < -1 || arg > 1) throw UnsupportedError('Invalid domain');
        final double res = math.asin(arg);
        return angleUnit == AngleUnit.deg ? res * (180.0 / math.pi) : res;
      case 'acos':
      case 'acos⁻¹':
      case 'cos⁻¹':
        if (arg < -1 || arg > 1) throw UnsupportedError('Invalid domain');
        final double res = math.acos(arg);
        return angleUnit == AngleUnit.deg ? res * (180.0 / math.pi) : res;
      case 'atan':
      case 'atan⁻¹':
      case 'tan⁻¹':
        final double res = math.atan(arg);
        return angleUnit == AngleUnit.deg ? res * (180.0 / math.pi) : res;
      case 'ln':
        if (arg <= 0) throw UnsupportedError('Invalid domain');
        return math.log(arg);
      case 'log':
        if (arg <= 0) throw UnsupportedError('Invalid domain');
        return math.log(arg) / math.ln10;
      case 'sqrt':
      case '√':
        if (arg < 0) throw UnsupportedError('Invalid domain');
        return math.sqrt(arg);
      case 'abs':
        return arg.abs();
      default:
        throw FormatException('Unknown function: $name');
    }
  }

  static double _cleanTrigResult(
      double val, double originalDeg, AngleUnit unit, bool isSin) {
    if (unit == AngleUnit.deg) {
      final double mod = (originalDeg % 360 + 360) % 360;
      if (isSin) {
        if (mod == 0 || mod == 180) return 0.0;
        if (mod == 30 || mod == 150) return 0.5;
        if (mod == 210 || mod == 330) return -0.5;
        if (mod == 90) return 1.0;
        if (mod == 270) return -1.0;
      } else {
        if (mod == 90 || mod == 270) return 0.0;
        if (mod == 60 || mod == 300) return 0.5;
        if (mod == 120 || mod == 240) return -0.5;
        if (mod == 0) return 1.0;
        if (mod == 180) return -1.0;
      }
    }
    return val;
  }

  static double _factorial(double n) {
    if (n < 0 || n != n.truncateToDouble() || n > 170) {
      throw UnsupportedError('Invalid factorial');
    }
    int intN = n.toInt();
    double result = 1.0;
    for (int i = 2; i <= intN; i++) {
      result *= i;
    }
    return result;
  }

  static String formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    if (value == 0.0) return '0';

    final double absVal = value.abs();
    if (absVal >= 1e12 || absVal < 1e-7) {
      return value.toStringAsPrecision(12).replaceAll(RegExp(r'\.?0+e'), 'e');
    }

    String formatted = value.toStringAsPrecision(12);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }
}
