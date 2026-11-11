# Ugali Preparation Language: Lexical Analysis (Theoretical Answers)

## a) Lexical Specification

Based on the Ugali Preparation Language (UPL) description, the lexemes are classified into the following token categories:

- **Reserved Words**: `PREPARE`, `INGREDIENTS`, `BOIL`, `WATER`, `ADD`, `FLOUR`, `STIR`, `PRESS`, `TURN`, `COOK`, `CHECK`, `CONSISTENCY`, `SHAPE`, `SERVE`, `UGALI`, `CUPS`, `MINUTES`.
- **Integer Literals**: `NUMBER`.
- **Identifiers**: `IDENTIFIER` (used for user-defined names).
- **Punctuation**: `SEMICOLON`.
- **Ignored tokens**: `WHITESPACE` and `COMMENT` (recognized by the scanner but discarded rather than passed to the parser).

## b) Regular Expressions

To recognize the lexical elements of UPL, the following regular expressions apply:

- **Integer literals**: `[0-9]+`
- **Identifiers**: `[a-zA-Z][a-zA-Z0-9_]*`
- **Whitespace**: `[ \t\r\n]+`
- **Single-line comments**: `\/\/[^\r\n]*`
- **Reserved words**: Exact string matches (e.g., `prepare`, `boil`, `water`).
- **Semicolon delimiter**: `;`

## d) Token Attributes

When the input `boil 4 cups water;` is parsed, it generates the stream: `BOIL`, `NUMBER(4)`, `CUPS`, `WATER`, `SEMICOLON`.

Storing the value `4` as a token attribute is crucial for later compiler phases (semantic analysis and code generation). While the parser only needs to know that a `NUMBER` was found to verify syntax (e.g., `Quantity -> NUMBER CUPS`), the semantic analyzer and code generator require the actual numerical value to execute or generate the exact instruction—knowing _how much_ water to boil, rather than just knowing that _some_ number was provided.

## e) Reserved Words versus Identifiers

When the scanner encounters `cooking_time` or `server`, it relies on JFlex's **longest-match rule**. JFlex always matches the longest possible string for a given token.

- For `cooking_time`, the scanner matches `cook` (4 characters) but also matches the `Identifier` rule for `cooking_time` (12 characters). It chooses `Identifier` because 12 > 4.
- For `server`, it matches `serve` (5 characters) but matches `server` as an `Identifier` (6 characters). It chooses the longer match.

Rule ordering is used as a tie-breaker when two rules match the exact same length of text. By placing reserved word rules before the generic `Identifier` rule, an input like `cook` matches both the reserved word `"cook"` and `Identifier`. Because `"cook"` is listed first, it correctly returns the reserved word token.

## f) Test the Scanner

For the valid test string provided, the resulting token stream is:

- `PREPARE`, `INGREDIENTS`, `SEMICOLON`
- `BOIL`, `NUMBER(4)`, `CUPS`, `WATER`, `SEMICOLON`
- `ADD`, `NUMBER(2)`, `CUPS`, `FLOUR`, `SEMICOLON`
- `STIR`, `SEMICOLON`
- `ADD`, `NUMBER(1)`, `CUPS`, `FLOUR`, `SEMICOLON`
- `STIR`, `SEMICOLON`
- `PRESS`, `UGALI`, `SEMICOLON`
- `TURN`, `UGALI`, `SEMICOLON`
- `COOK`, `NUMBER(8)`, `MINUTES`, `SEMICOLON`
- `CHECK`, `CONSISTENCY`, `SEMICOLON`
- `SHAPE`, `UGALI`, `SEMICOLON`
- `SERVE`, `UGALI`, `SEMICOLON`

_(Note: The comment `// Ugali preparation program` is ignored.)_

## g) Lexical Error Detection

For the invalid input:

```text
prepare ingredients;
boil 4 cups water;
add @2 cups flour;
cook 5# minutes;
```

The scanner should identify `@` and `#` as illegal characters. Assuming 1-based indexing for both line and column:

- `Lexical error at line 3, column 5: illegal character '@'`
- `Lexical error at line 4, column 6: illegal character '#'` (Column is 6 since `cook ` takes 5 spaces).

## i) Scanner and Parser Relationship

A JFlex scanner integrates directly with a parser generator like CUP. The scanner implements an interface featuring a `next_token()` method. Each time the CUP parser needs to make a shift or reduce decision, it calls `next_token()`. The scanner reads the character stream, matches the lexemes, and returns `Symbol` objects (which encapsulate the token type, line/column metadata, and token attributes like integer values).

- **Symbol Table**: The scanner might populate it or pass the string attribute to the parser/semantic analyzer, which then handles scoping and symbol table entries.
- **Error Separation**: Lexical errors occur when a character sequence does not match any valid regex (e.g., an illegal `@`). Syntax errors occur when valid tokens are generated, but their sequence violates the context-free grammar rules (e.g., `BOIL WATER CUPS`).

## j) Analysis Question

For the input `boil four cups water;`:

1.  **Tokens Generated**: `BOIL`, `IDENTIFIER("four")`, `CUPS`, `WATER`, `SEMICOLON`.
2.  **Lexical Error?**: No. The scanner matches `four` perfectly to the `Identifier` regular expression. It generates valid tokens.
3.  **Detecting Compiler Phase**: The **Syntax Analyzer (Parser)** will detect the error. When trying to resolve the rule `Boiling -> BOIL Quantity WATER SEMICOLON` and `Quantity -> NUMBER CUPS`, it expects a `NUMBER` token but receives an `IDENTIFIER` token.
4.  **Separation of Concerns**: This demonstrates that the lexical analyzer only cares about grouping characters into valid, distinct words (tokens) based on regular expressions. It has no understanding of sentence structure. The syntax analyzer (parser) enforces grammatical structure (context-free grammar) and ensures the valid words are placed in an order that makes logical sense for the language.
