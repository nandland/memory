library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_Dual_Port_TB is
end RAM_Dual_Port;

architecture TB of RAM_Dual_Port is

begin

  UUT : entity work.RAM_Dual_Port
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
  
  -- Purpose: Control Writes to Memory.
  p_Write : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      if i_Wr_DV = '1' then
        r_Mem(to_integer(unsigned(i_Wr_Addr))) <= i_Wr_Data;
      end if;
    end if;
  end process p_Write;

  -- Purpose: Control Reads From Memory.
  p_Read : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      o_Rd_Data <= r_Mem(to_integer(unsigned(i_Rd_Addr)));
    end if;
  end process p_Read;

end RTL;
