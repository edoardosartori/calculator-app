import 'tokenizer.dart';

abstract class ExpressionNode {}

class NumberNode extends ExpressionNode {
  NumberNode(this.value);
  final double value;
}

class ConstantNode extends ExpressionNode {
  ConstantNode(this.name);
  final String name;
}

class UnaryOpNode extends ExpressionNode {
  UnaryOpNode(this.operator, this.operand);
  final String operator;
  final ExpressionNode operand;
}

class BinaryOpNode extends ExpressionNode {
  BinaryOpNode(this.left, this.operator, this.right);
  final ExpressionNode left;
  final String operator;
  final ExpressionNode right;
}

class FunctionNode extends ExpressionNode {
  FunctionNode(this.name, this.argument);
  final String name;
  final ExpressionNode argument;
}

class Parser {
  Parser(this.tokens);
  final List<Token> tokens;
  int _position = 0;

  Token get _currentToken => _position < tokens.length
      ? tokens[_position]
      : const Token(TokenType.operator, 'EOF');

  ExpressionNode parse() {
    if (tokens.isEmpty) {
      throw FormatException('Empty expression');
    }
    final result = _parseAddSub();
    if (_position < tokens.length) {
      throw FormatException('Unexpected token: ${_currentToken.value}');
    }
    return result;
  }

  ExpressionNode _parseAddSub() {
    ExpressionNode left = _parseMulDiv();

    while (_currentToken.type == TokenType.operator &&
        (_currentToken.value == '+' ||
            _currentToken.value == '-' ||
            _currentToken.value == '−')) {
      final String op = _currentToken.value;
      _position++;
      final ExpressionNode right = _parseMulDiv();
      left = BinaryOpNode(left, op, right);
    }

    return left;
  }

  ExpressionNode _parseMulDiv() {
    ExpressionNode left = _parsePostfix();

    while (_currentToken.type == TokenType.operator &&
        (_currentToken.value == '*' ||
            _currentToken.value == '×' ||
            _currentToken.value == '/' ||
            _currentToken.value == '÷' ||
            _currentToken.value == '%')) {
      final String op = _currentToken.value;
      _position++;
      final ExpressionNode right = _parsePostfix();
      left = BinaryOpNode(left, op, right);
    }

    return left;
  }

  ExpressionNode _parsePostfix() {
    ExpressionNode node = _parsePower();

    while (_currentToken.type == TokenType.operator &&
        _currentToken.value == '!') {
      _position++;
      node = UnaryOpNode('!', node);
    }

    return node;
  }

  ExpressionNode _parsePower() {
    ExpressionNode left = _parseUnary();

    if (_currentToken.type == TokenType.operator &&
        _currentToken.value == '^') {
      _position++;
      final ExpressionNode right = _parsePower(); // Right-associative
      return BinaryOpNode(left, '^', right);
    }

    return left;
  }

  ExpressionNode _parseUnary() {
    if (_currentToken.type == TokenType.operator &&
        (_currentToken.value == '-' || _currentToken.value == '−')) {
      _position++;
      final ExpressionNode operand = _parseUnary();
      return UnaryOpNode('-', operand);
    }
    return _parsePrimary();
  }

  ExpressionNode _parsePrimary() {
    final Token token = _currentToken;

    if (token.type == TokenType.number) {
      _position++;
      if (token.value == 'π' || token.value == 'e') {
        return ConstantNode(token.value);
      }
      final double? parsed = double.tryParse(token.value);
      if (parsed == null) {
        throw FormatException('Invalid number format: ${token.value}');
      }
      return NumberNode(parsed);
    }

    if (token.type == TokenType.function) {
      final String fnName = token.value;
      _position++;
      final ExpressionNode arg = _parsePrimary();
      return FunctionNode(fnName, arg);
    }

    if (token.type == TokenType.leftParen) {
      _position++;
      final ExpressionNode expr = _parseAddSub();
      if (_currentToken.type != TokenType.rightParen) {
        throw FormatException('Mismatched parentheses');
      }
      _position++;
      return expr;
    }

    throw FormatException('Unexpected token: ${token.value}');
  }
}
