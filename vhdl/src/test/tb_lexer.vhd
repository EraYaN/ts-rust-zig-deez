-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2023, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

library lexer_lib;

entity tb_lexer is
  generic (
    runner_cfg : string;
    tb_path    : string;
    text_i      : string := "input.txt";
    text_o      : string := "output.txt"
    );
end entity;

architecture tb of tb_lexer is
  constant baud_rate : integer := 115200; -- bits / s
  constant clk_period : integer := 20; -- ns
  constant cycles_per_bit : integer := 50 * 10**6 / baud_rate;

  signal clk : std_logic := '0';
  signal in_tready : std_logic := '0';
  signal in_tvalid : std_Logic;
  signal in_tdata : std_logic_vector(7 downto 0);
  signal out_tready : std_logic;
  signal out_tvalid : std_Logic;
  signal out_tdata : std_logic_vector(7 downto 0);



  file text_file : text open read_mode is tb_path & text_i;

  constant axi_input_bfm : axi_stream_master_t := new_axi_stream_master(
    data_length => in_tdata'length,
    stall_config => new_stall_config(0.05, 1, 10)
    );
  constant axi_input_stream : stream_master_t := as_stream(axi_input_bfm);

  constant axi_output_bfm : axi_stream_slave_t := new_axi_stream_slave(
    data_length => out_tdata'length,
    stall_config => new_stall_config(0.05, 1, 10)
  );
  constant axi_output_stream : stream_slave_t := as_stream(axi_output_bfm);
begin

  main : process
  variable read_char : character;
  variable read_ok: boolean := true;
  variable file_data : std_logic_vector(7 downto 0);
  variable file_line     :line;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      reset_checker_stat;
      if run("test_receives_file") then

        while not endfile(text_file) loop
          info("Reading line...");
          readline(text_file, file_line);
          read(file_line, read_char, read_ok);
          while read_ok loop
            file_data := std_logic_vector(to_unsigned(character'pos(read_char),8));
            push_stream(net, axi_input_stream, file_data);
            check_stream(net, axi_output_stream, file_data, true);
            wait until rising_edge(clk);
            check_equal(out_tvalid, '0');
            read(file_line, read_char, read_ok);
          end loop;
          -- send newline for each processed line.
          push_stream(net, axi_input_stream, x"0A");
          check_stream(net, axi_output_stream, x"0A", true);
        end loop;
      end if;
    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;
  test_runner_watchdog(runner, 10 ms);

  clk <= not clk after (clk_period/2) * 1 ns;

  dut : entity lexer_lib.lexer
    generic map (
      cycles_per_bit => cycles_per_bit)
    port map (
      clk => clk,
      in_tready => in_tready,
      in_tvalid => in_tvalid,
      in_tdata => in_tdata,
      out_tready => out_tready,
      out_tvalid => out_tvalid,
      out_tdata => out_tdata);

  axi_stream_input_bfm: entity vunit_lib.axi_stream_master
    generic map (
      master => axi_input_bfm)
    port map (
      aclk   => clk,
      tvalid => in_tvalid,
      tready => in_tready,
      tdata  => in_tdata);

  axi_stream_output_bfm: entity vunit_lib.axi_stream_slave
    generic map (
      slave => axi_output_bfm)
    port map (
      aclk   => clk,
      tvalid => out_tvalid,
      tready => out_tready,
      tdata  => out_tdata);

end architecture;
