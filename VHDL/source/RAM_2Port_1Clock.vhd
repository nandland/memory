-- Russell Merrick - http://www.nandland.com
--
-- Creates a Dual (2) Port RAM running off a single clock. 
-- Single port RAM has one port, so can only access one memory location at a time.
-- Dual port RAM can read and write to different memory locations at the same time.
-- 
-- Generic: WIDTH sets the width of the Memory created.
-- Generic: DEPTH sets the depth of the Memory created.
-- Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
-- If small, tools will infer register-based memory.
-- 
-- Uses a single clock for both ports, so can't be used to cross clock domains.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_2Port_1Clock is
  generic (
    DEPTH : integer := 64;
    WIDTH : integer := 2
    );
  port (
    i_Clk     : in  std_logic;
    i_Wr_Addr : in  std_logic_vector; -- Gets sized at higher level
    i_Wr_Data : in  std_logic_vector(WIDTH-1 downto 0);
    i_Wr_DV   : in  std_logic;
    i_Rd_Addr : in  std_logic_vector; -- Gets sized at higher level
    o_Rd_Data : out std_logic_vector(WIDTH-1 downto 0)
    );
end RAM_2Port_1Clock;

architecture RTL of RAM_2Port_1Clock is

  -- Create Memory that is DEPTH x WIDTH
  type t_Mem is array (DEPTH-1 to 0) of std_logic_vector(WIDTH-1 downto 0);
  signal r_Mem : t_Mem := (others => (others => '0'));

begin

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
