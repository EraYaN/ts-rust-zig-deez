library ieee;
use ieee.std_logic_1164.all;

library work;

package tokens is

  -- chip space is expensive, you get 6
  constant c_MAX_LIT_LEN : integer := 6;

  type token_type_t is (
    TOKEN_ILLEGAL,
    TOKEN_EOF,
    TOKEN_IDENT,
    TOKEN_IF,
    TOKEN_RETURN,
    TOKEN_TRUE,
    TOKEN_FALSE,
    TOKEN_ELSE,
    TOKEN_INT,
    TOKEN_ASSIGN,
    TOKEN_NOTEQUAL,
    TOKEN_EQUAL,
    TOKEN_PLUS,
    TOKEN_COMMA,
    TOKEN_SEMICOLON,
    TOKEN_LPAREN,
    TOKEN_RPAREN,
    TOKEN_LSQUIRLY,
    TOKEN_RSQUIRLY,
    TOKEN_FUNCTION,
    TOKEN_LET,
    TOKEN_BANG,
    TOKEN_DASH,
    TOKEN_FORWARDSLASH,
    TOKEN_ASTERISK,
    TOKEN_LESSTHAN,
    TOKEN_GREATERTHAN
  );

  type token_t is record
    token_type : token_type_t;
    token_literal : std_logic_vector(8*c_MAX_LIT_LEN-1 downto 0);
  end record token_t;

end package tokens;
