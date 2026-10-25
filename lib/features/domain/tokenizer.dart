enum TokenType {
  number,
  operator,
  function,
  leftParen,
  rightParen,
  comma,
}

class Token {
  const Token(this.type, this.value);

  final TokenType type;
  final String value;

  @override
  String toString() => 'Token($type, $value)';
}

class Tokenizer {
  static const Set<String> _operators = {
    '+',
    '-',
    '−',
    '*',
    '×',
    '/',
    '÷',
    '^',
    '%',
    '!'
  };

  // Longest names first: 'sin⁻¹' must be matched before 'sin'.
  static const List<String> _functions = [
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
    '√',
    'abs',
  ];

  static List<Token> tokenize(String input) {
    final List<Token> tokens = [];
    int i = 0;

    while (i < input.length) {
      final String char = input[i];

      if (char.trim().isEmpty) {
        i++;
        continue;
      }

      if (_isDigit(char) || char == '.') {
        final StringBuffer buffer = StringBuffer();
        while (i < input.length && (_isDigit(input[i]) || input[i] == '.')) {
          buffer.write(input[i]);
          i++;
        }
        tokens.add(Token(TokenType.number, buffer.toString()));
        continue;
      }

      if (char == 'π' || char == 'e') {
        tokens.add(Token(TokenType.number, char));
        i++;
        continue;
      }

      if (char == '(') {
        tokens.add(const Token(TokenType.leftParen, '('));
        i++;
        continue;
      }

      if (char == ')') {
        tokens.add(const Token(TokenType.rightParen, ')'));
        i++;
        continue;
      }

      if (char == '|') {
        tokens.add(const Token(TokenType.function, 'abs'));
        i++;
        continue;
      }

      bool matchedFunction = false;
      for (final String fn in _functions) {
        if (input.startsWith(fn, i)) {
          tokens.add(Token(TokenType.function, fn));
          i += fn.length;
          matchedFunction = true;
          break;
        }
      }
      if (matchedFunction) continue;

      if (_operators.contains(char)) {
        tokens.add(Token(TokenType.operator, char));
        i++;
        continue;
      }

      i++;
    }

    return _insertImplicitMultiplications(tokens);
  }

  static bool _isDigit(String char) {
    final int code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static List<Token> _insertImplicitMultiplications(List<Token> tokens) {
    if (tokens.isEmpty) return tokens;

    final List<Token> result = [tokens.first];

    for (int i = 1; i < tokens.length; i++) {
      final Token prev = tokens[i - 1];
      final Token curr = tokens[i];

      final bool prevCanEndValue = prev.type == TokenType.number ||
          prev.type == TokenType.rightParen ||
          prev.value == '!';

      final bool currCanStartValue = curr.type == TokenType.number ||
          curr.type == TokenType.function ||
          curr.type == TokenType.leftParen;

      if (prevCanEndValue && currCanStartValue) {
        result.add(const Token(TokenType.operator, '×'));
      }

      result.add(curr);
    }

    return result;
  }
}
