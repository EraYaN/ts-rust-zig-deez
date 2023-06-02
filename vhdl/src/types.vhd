library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is

    subtype byte is std_logic_vector(7 downto 0);

    function to_byte(c : character) return byte;

    function to_character(b: byte) return character;

    function is_alpha(c: character) return boolean;

end package types;


-- Package Body Section
package body types is
 
    function to_byte(c : character) return byte is
    begin
        return byte(to_unsigned(character'pos(c), 8));
    end function;

    function to_character(b: byte) return character is
    begin
        return character'val(to_integer(unsigned(b)));
    end function;
   
    function is_alpha(c: character) return boolean is
      begin
          return (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z');
      end function;

  end package body types;
