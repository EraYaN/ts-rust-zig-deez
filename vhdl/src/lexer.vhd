library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
library vunit_lib;
use vunit_lib.check_pkg.all;
use vunit_lib.logger_pkg.all;

-- pragma translate_on

library work;
use work.tokens.all;

entity lexer is
  generic (
    cycles_per_bit : natural := 434);
  port (
   clk : in std_logic;

   -- AXI stream for input bytes
   in_tready : out std_logic;
   in_tvalid : in std_Logic := '0';
   in_tdata : in std_logic_vector(7 downto 0);

   -- AXI stream for output bytes
   out_tready : in std_logic;
   out_tvalid : out std_Logic := '0';
   out_tdata : out std_logic_vector(7 downto 0)
  );
begin
  -- pragma translate_off
  check_stable(clk, check_enabled, out_tvalid, out_tready, out_tdata, "out_tdata must be stable until out_tready is active");
  check_stable(clk, check_enabled, out_tvalid, out_tready, out_tvalid, "out_tvalid must be active until out_tready is active");
  check_not_unknown(clk, check_enabled, out_tvalid, "out_tvalid must never be unknown");
  check_not_unknown(clk, check_enabled, out_tready, "out_tready must never be unknown");
  --check_not_unknown(clk, check_enabled, in_tready, "in_tready must never be unknown");
  --check_not_unknown(clk, check_enabled, in_tvalid, "in_tvalid must never be unknown");
  traffic_logger: process (clk) is
  begin
    if out_tvalid = '1' and out_tready = '1' and rising_edge(clk) then
      debug("Received " & to_string(to_integer(unsigned(out_tdata))));
    end if;
  end process traffic_logger;
  -- pragma translate_on
end entity;

architecture a of lexer is
  signal tokenizer_in_clk : std_logic := '0';
  signal tdata : std_logic_vector(7 downto 0);
  signal out_tvalid_int : std_logic := '0';
begin
  main : process (clk)
    type state_t is (idle, receiving, processing, writing);
    variable state : state_t := idle;
    -- variable cycles : natural range 0 to cycles_per_bit-1 := 0;
    
    -- variable index : natural range 0 to data'length-1 := 0;
  begin
    if rising_edge(clk) then

      case state is
        when idle => 
          if in_tvalid = '1' and out_tvalid_int = '0' then
            state := receiving;
          else 
            in_tready <= '0';
          end if;
        when receiving =>
          tdata <= in_tdata;
          in_tready <= '1';
          state := processing;
        when processing =>
          state := writing;
        when writing =>
          out_tdata <= tdata;
          out_tvalid_int <= '1';
          state := idle;
      end case;

      -- output was read
      if out_tvalid_int = '1' and out_tready = '1' then
        out_tvalid_int <= '0';
        out_tdata <= (others => 'X');
      end if;

    end if;
  end process;

  out_tvalid <= out_tvalid_int;
  tokenizer_in_clk <= out_tvalid_int;

  tokenizer : entity work.tokenizer
    port map (
      clk => clk,
      in_char => tdata,
      char_clk => tokenizer_in_clk);
end architecture;
