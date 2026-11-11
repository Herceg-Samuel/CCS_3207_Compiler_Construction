%%

%class UgaliLexer
%unicode
%line
%column
%standalone

// Regular Expressions
LineTerminator = \r|\n|\r\n
WhiteSpace     = {LineTerminator} | [ \t\f]
Comment        = "//" [^\r\n]*
Identifier     = [a-zA-Z][a-zA-Z0-9_]*
Number         = [0-9]+

%%

<YYINITIAL> {
  // Reserved Words
  "prepare"      { System.out.println("PREPARE"); }
  "ingredients"  { System.out.println("INGREDIENTS"); }
  "boil"         { System.out.println("BOIL"); }
  "water"        { System.out.println("WATER"); }
  "add"          { System.out.println("ADD"); }
  "flour"        { System.out.println("FLOUR"); }
  "stir"         { System.out.println("STIR"); }
  "press"        { System.out.println("PRESS"); }
  "turn"         { System.out.println("TURN"); }
  "cook"         { System.out.println("COOK"); }
  "check"        { System.out.println("CHECK"); }
  "consistency"  { System.out.println("CONSISTENCY"); }
  "shape"        { System.out.println("SHAPE"); }
  "serve"        { System.out.println("SERVE"); }
  "ugali"        { System.out.println("UGALI"); }
  "cups"         { System.out.println("CUPS"); }
  "minutes"      { System.out.println("MINUTES"); }

  // Semicolon
  ";"            { System.out.println("SEMICOLON"); }

  // Integer Literals (with token attribute)
  {Number}       { System.out.println("NUMBER (" + yytext() + ")"); }

  // Identifiers
  {Identifier}   { System.out.println("IDENTIFIER (" + yytext() + ")"); }

  // Ignored Characters
  {Comment}      { /* ignore */ }
  {WhiteSpace}   { /* ignore */ }
}

// Error Fallback
[^]              { System.err.printf("Lexical error at line %d, column %d: illegal character '%s'\n", yyline+1, yycolumn+1, yytext()); }