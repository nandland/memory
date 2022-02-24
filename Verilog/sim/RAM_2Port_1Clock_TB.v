// Russell Merrick - http://www.nandland.com
//
// Dual Port RAM testbench.

module RAM_2Port_1Clock_TB ();

  localparam DEPTH = 4;
  localparam WIDTH = 8;

  reg r_Clk = 1'b0;
  reg r_PortA_WE = 1'b0, r_PortB_WE = 1'b0;
  reg [$clog2(DEPTH)-1:0] r_PortA_Addr = 0, r_PortB_Addr = 0;
  reg [WIDTH-1:0] r_PortA_Data = 0, r_PortB_Data = 0;
  wire [WIDTH-1:0] w_PortA_Data, w_PortB_Data;
  
  always #10 r_Clk <= !r_Clk; // create oscillating clock

  RAM_2Port_1Clock #(.WIDTH(WIDTH), .DEPTH(DEPTH)) UUT 
  (.i_Clk(r_Clk),
  // Port A
  .i_PortA_Data(r_PortA_Data),
  .i_PortA_Addr(r_PortA_Addr),
  .i_PortA_WE(r_PortA_WE),
  .o_PortA_Data(w_PortA_Data),
  // Port B
  .i_PortB_Data(r_PortB_Data),
  .i_PortB_Addr(r_PortB_Addr),
  .i_PortB_WE(r_PortB_WE),
  .o_PortB_Data(w_PortB_Data)
  );

  initial
  begin 
    $dumpfile("dump.vcd"); $dumpvars; // for EDA Playground sim
    
    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to start

    // Fill memory with incrementing pattern
    repeat(DEPTH)
    begin
      r_PortA_WE <= 1'b1;
      @(posedge r_Clk);
      r_PortA_Data <= r_PortA_Data + 1;
      r_PortA_Addr <= r_PortA_Addr + 1;
    end

    // Read out incrementing pattern
    repeat(DEPTH)
    begin
      @(posedge r_Clk);
      r_PortB_Addr <= r_PortB_Addr + 1;
	  end

    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to end

    $finish();
  end

endmodule
