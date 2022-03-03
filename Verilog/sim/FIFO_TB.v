// Russell Merrick - http://www.nandland.com
//
// FIFO testbench.

module FIFO_TB ();

  localparam DEPTH = 4;
  localparam WIDTH = 8;
  localparam MAKE_FWFT = 1;

  reg r_Clk = 1'b0, r_Rst_L = 1'b0;
  reg r_Wr_DV = 1'b0, r_Rd_En = 1'b0;
  reg [WIDTH-1:0] r_Wr_Data = 0;
  reg [$clog2(DEPTH)-1:0] r_AF_Level = 0, r_AE_Level = 0;
  wire w_AF_Flag, w_AE_Flag, w_Full, w_Empty, w_Rd_DV;
  wire [WIDTH-1:0] w_Rd_Data;
  
  always #10 r_Clk <= !r_Clk; // create oscillating clock

  FIFO #(.WIDTH(WIDTH), .DEPTH(DEPTH), .MAKE_FWFT(MAKE_FWFT)) UUT 
  (
  .i_Rst_L(r_Rst_L),
  .i_Clk(r_Clk),
  // Write Side
  .i_Wr_DV(r_Wr_DV),
  .i_Wr_Data(r_Wr_Data),
  .i_AF_Level(r_AF_Level),
  .o_AF_Flag(w_AF_Flag),
  .o_Full(w_Full),
  // Read Side
  .i_Rd_En(r_Rd_En),
  .o_Rd_DV(w_Rd_DV),
  .o_Rd_Data(w_Rd_Data),
  .i_AE_Level(r_AE_Level),
  .o_AE_Flag(w_AE_Flag),
  .o_Empty(w_Empty)
  );

  initial
  begin 
    $dumpfile("dump.vcd"); $dumpvars; // for EDA Playground sim
    
    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to start
    r_Rst_L <= 1'b1; // Release reset
    repeat(4) @(posedge r_Clk);

    // Fill FIFO with incrementing pattern
    repeat(DEPTH)
    begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
      r_Wr_DV <= 1'b0;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1;
    end
    r_Wr_DV <= 1'b0;

    // Read out incrementing pattern
    repeat(DEPTH)
    begin
      r_Rd_En <= 1'b1;
      @(posedge r_Clk);
      r_Rd_En <= 1'b0;
      @(posedge r_Clk);
	  end
    r_Rd_En   <= 1'b0;

    repeat(4) @(posedge r_Clk); 

    // Test reading and writing at the same time
    r_Wr_Data <= 84;
    r_Rd_En <= 1'b1;
    r_Wr_DV <= 1'b1;
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    r_Wr_DV <= 1'b0;
    repeat(3) @(posedge r_Clk);
    r_Rd_En <= 1'b1;
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    repeat(3) @(posedge r_Clk);
    
    $finish();
  end

endmodule
