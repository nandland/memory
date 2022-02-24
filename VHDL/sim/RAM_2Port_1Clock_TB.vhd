library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_2Port_1Clock_TB is
end RAM_2Port_1Clock_TB;

architecture test of RAM_2Port_1Clock_TB is
begin

  UUT : entity work.RAM_2Port_1Clock
    generic map (
      DEPTH => 64,
      WIDTH => 2)
    port map (
      i_Clk     => r_Clock,
      i_Wr_Addr => r_Wr_Addr,
      i_Wr_Data => r_Wr_Data,
      i_Wr_DV   => r_Wr_DV,
      i_Rd_Addr => r_Rd_Addr,
      o_Rd_Data => r_Rd_Data);
  
end test;
