-- Russell Merrick - http://www.nandland.com
--
-- Infers a Dual Port RAM (DPRAM) Based FIFO using a single clock
-- Uses a Dual Port RAM but automatically handles read/write addresses.
-- To use Almost Full/Empty Flags (dynamic)
-- Set i_AF_Level to number of words away from full when o_AF_Flag goes high
-- Set i_AE_Level to number of words away from empty when o_AE goes high
--   o_AE_Flag is high when this number OR LESS is in FIFO.
--
-- Generics: 
-- WIDTH     - Width of the FIFO
-- DEPTH     - Max number of items able to be stored in the FIFO
-- MAKE_FWFT - Use First-Word Fall Through. Make output immediately
--             have first written word.  1=FWFT, 0=Regular
--
-- This FIFO cannot be used to cross clock domains, because in order to keep count
-- correctly it would need to handle all metastability issues. 
-- If crossing clock domains is required, use FIFO primitives directly from the vendor.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO is 
  generic (
    WIDTH     : integer := 8;
    DEPTH     : integer := 256;
    MAKE_FWFT : boolean := false);
  port (
    i_Rst_L : in std_logic;
    i_Clk   : in std_logic;
    -- Write Side
    i_Wr_DV    : in  std_logic;
    i_Wr_Data  : in  std_logic_vector(WIDTH-1 downto 0);
    i_AF_Level : in  integer;
    o_AF_Flag  : out std_logic;
    o_Full     : out std_logic;
    -- Read Side
    i_Rd_En    : in  std_logic;
    o_Rd_DV    : out std_logic;
    o_Rd_Data  : out std_logic_vector(WIDTH-1 downto 0);
    i_AE_Level : in  integer;
    o_AE_Flag  : out std_logic;
    o_Empty    : out std_logic);

  signal r_Wr_Addr, r_Rd_Addr : natural range 0 to DEPTH-1;
  signal r_Count : natural range 0 to DEPTH;  -- 1 extra to go to DEPTH
 
  signal w_Rd_DV : std_logic;
  signal w_Rd_Data : std_logic_vector(WIDTH-1 downto 0);

  -- Dual Port RAM used for storing Information bytes
  UUT : entity work. #(.WIDTH(WIDTH), .DEPTH(DEPTH)) FIFO_Inst 
    (-- Write Port
     .i_Wr_Clk(i_Clk),   
     .i_Wr_Addr(r_Wr_Addr),
     .i_Wr_DV(i_Wr_DV),
     .i_Wr_Data(i_Wr_Data),
     -- Read Port
     .i_Rd_Clk(i_Clk),
     .i_Rd_Addr(r_Rd_Addr),
     .i_Rd_En(i_Rd_En),
     .o_Rd_DV(w_Rd_DV),
     .o_Rd_Data(w_Rd_Data)
     );

  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r_Wr_Addr <= 0;
      r_Rd_Addr <= 0;
      r_Count   <= 0;
    end
    else
    begin
      -- Write
      if (i_Wr_DV)
      begin
        if (r_Wr_Addr == DEPTH-1)
          r_Wr_Addr <= 0;
        else
          r_Wr_Addr <= r_Wr_Addr + 1;
      end

      -- Read
      if (i_Rd_En)
      begin
        if (r_Rd_Addr == DEPTH-1)
          r_Rd_Addr <= 0;
        else
          r_Rd_Addr <= r_Rd_Addr + 1;
      end

      -- Keeps track of number of words in FIFO
      -- Read with no write
      if (i_Rd_En & ~i_Wr_DV)
      begin
        if (r_Count != 0)
        begin
          r_Count <= r_Count - 1;
        end
      end
      -- Write with no read
      else if (i_Wr_DV & ~i_Rd_En)
      begin
        if (r_Count != DEPTH)
        begin
          r_Count <= r_Count + 1;
        end
      end

      -- Handle FWFT 
      if (i_Wr_DV & o_Empty & (MAKE_FWFT == 1))
      begin
        o_Rd_Data <= i_Wr_Data;
      end
      else if (i_Rd_En)
      begin
        o_Rd_Data <= w_Rd_Data;
      end

    end -- else: !if(~i_Rst_L)
  end -- always @ (posedge i_Clk or negedge i_Rst_L)


  assign o_Full  = (r_Count == DEPTH) || (r_Count == DEPTH-1 && i_Wr_DV && !i_Rd_En);
  
  assign o_Empty = (r_Count == 0);

  assign o_AF_Flag = (r_Count > DEPTH - i_AF_Level);
  assign o_AE_Flag = (r_Count < i_AE_Level);

  assign o_Rd_DV = w_Rd_DV;

  ----------------------------------------------------------------------------/
  -- ASSERTION CODE, NOT SYNTHESIZED
  -- synthesis translate_off
  -- Ensures that we never read from empty FIFO or write to full FIFO.
  always @(posedge i_Clk)
  begin
    if (i_Rd_En && !i_Wr_DV && r_Count == 0)
    begin
      $error("Error! Reading Empty FIFO");
    end

    if (i_Wr_DV && !i_Rd_En && r_Count == DEPTH)
    begin
      $error("Error! Writing Full FIFO");
    end
  end
  -- synthesis translate_on
  ----------------------------------------------------------------------------/
  
endmodule
