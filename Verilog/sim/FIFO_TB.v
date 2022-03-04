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

  reg r_Test_Rd_On_Empty = 1'b0;
  wire w_Rd_Mux;

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
  .i_Rd_En(w_Rd_Mux),
  .o_Rd_DV(w_Rd_DV),
  .o_Rd_Data(w_Rd_Data),
  .i_AE_Level(r_AE_Level),
  .o_AE_Flag(w_AE_Flag),
  .o_Empty(w_Empty)
  );

  assign w_Rd_Mux = r_Test_Rd_On_Empty ? !w_Empty : r_Rd_En;

  // To Test:
  // Read when empty flag is false with always block (gated with another signal)
  // Write when full flag is false with always block (gated with another signal)
  // almost full/empty flags work as intended

  initial
  begin 
    integer i;
    $dumpfile("dump.vcd"); $dumpvars; // for EDA Playground sim
    
    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to start
    r_Rst_L <= 1'b1; // Release reset
    repeat(4) @(posedge r_Clk);

    // Write single word, ensure it appears on output
    r_Wr_DV   <= 1'b1;
    r_Wr_Data <= 8'hAB;
    @(posedge r_Clk);
    r_Wr_DV   <= 1'b0;
    @(posedge r_Clk);
    assert (!w_Empty);
    assert (w_Rd_Data == 8'hAB); // test FWFT

    repeat(4) @(posedge r_Clk);

    // Read out that word, ensure DV and empty is correct
    r_Rd_En <= 1'b1;
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    @(posedge r_Clk);
    assert (w_Rd_DV);
    assert (w_Empty);
    assert (w_Rd_Data == 8'hAB);
        
    repeat(4) @(posedge r_Clk);

    // Fill FIFO with incrementing pattern
    r_Wr_Data <= 8'h30;
    repeat(DEPTH)
    begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
      r_Wr_DV <= 1'b0;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1;
    end
    r_Wr_DV <= 1'b0;
    @(posedge r_Clk);
    assert (w_Full);
    @(posedge r_Clk);

    // Read out and verify incrementing pattern
    for (i=8'h30; i<8'h30 + DEPTH; i=i+1)
    begin
      r_Rd_En <= 1'b1;
      @(posedge r_Clk);
      r_Rd_En <= 1'b0;
      @(posedge r_Clk);
      assert (w_Rd_DV);
      assert (w_Rd_Data == i) else $error("rd_data is %d i is %d", w_Rd_Data, i);
      @(posedge r_Clk);
    end
    assert (w_Empty);

    repeat(4) @(posedge r_Clk); 

    /*
    // Test ability to read by using the empty flag
    r_Test_Rd_On_Empty <= 1'b1;
    repeat(DEPTH)
    begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1;
    end
    r_Wr_DV <= 1'b0;
    repeat(3) @(posedge r_Clk); 
    r_Test_Rd_On_Empty <= 1'b0;

    repeat(4) @(posedge r_Clk); 

    // Test ability to write until we are full
    while (!w_Full)
    begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
    end
    r_Wr_DV <= 1'b0;

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
    */
    $finish();
  end

endmodule
