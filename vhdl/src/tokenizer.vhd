library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tokens.all;
use work.types.all;

entity tokenizer is
  port (
   clk : in std_logic;

   char_clk : in std_logic;
   in_char : in byte;

   token_ready : out std_logic;
   out_token : out std_logic_vector(8*c_MAX_LIT_LEN-1 downto 0)
  );
end entity;

architecture a of tokenizer is
  signal debug_idx : integer;
begin
  main : process (clk)
    variable char: character;
    variable char_buffer : std_logic_vector(8*c_MAX_LIT_LEN-1 downto 0);
    variable idx : integer := 0;
  begin
    if rising_edge(clk) then
      if rising_edge(char_clk) then
        char:=to_character(in_char);
        if is_alpha(char) then
          char_buffer(8*(c_MAX_LIT_LEN-idx)-1 downto 8*(c_MAX_LIT_LEN-idx-1)) := in_char;
          if idx = c_MAX_LIT_LEN-1 then
            idx := 0;
            token_ready <= '1';
            out_token <= char_buffer;
          else
            idx := idx + 1;
            token_ready <= '0';
          end if;
        else
          idx := 0;
          token_ready <= '1';
          char_buffer(8*(c_MAX_LIT_LEN-idx)-1 downto 8*(c_MAX_LIT_LEN-idx-1)) := in_char;
          char_buffer(8*(c_MAX_LIT_LEN-idx-1) -1 downto 0) := (others => 'X');
          out_token <= char_buffer;
        end if;
      end if;
      debug_idx <= idx;
    end if;
  end process;

  
end architecture;
