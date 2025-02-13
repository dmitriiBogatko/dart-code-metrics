# Cyclomatic Complexity

Number of linearly independent paths through a block of code. Presence of conditional operators or loops increases the number of paths in a code. The more paths, the higher the number of test cases that need to be implemented. The metric complies with McCabe's original definition:

* Methods have a base complexity of 1.
* every control flow statement (`if`, `catch`, `throw`, `do`, `while`, `for`, `break`, `continue`) and conditional expression (`? ... : ...`) increase complexity
* `else`, `finally` and `default` don't count
* some operators (`&&`, `||`, `?.`, `??`, `??=`) increase complexity

Example:

```dart
void visitBlock(Token firstToken, Token lastToken) {
  const tokenTypes = [
    TokenType.AMPERSAND_AMPERSAND,
    TokenType.BAR_BAR,
    TokenType.QUESTION_PERIOD,
    TokenType.QUESTION_QUESTION,
    TokenType.QUESTION_QUESTION_EQ,
  ];

  var token = firstToken;
  while (token != lastToken) {
    if (token.matchesAny(tokenTypes)) {
      _increaseComplexity(token);
    }

    token = token.next;
  }
}
```

**Cyclomatic Complexity** for example function is **3**.
