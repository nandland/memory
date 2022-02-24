// Russell Merrick - http://www.nandland.com
//
// Single Port RAM testbench.

module RAM_1Port_TB ();

  localparam DEPTH = 4;
  localparam WIDTH = 8;

  reg r_Clk = 1'b0;
  reg r_WE = 1'b0;
  reg [$clog2(DEPTH)-1:0] r_Addr = 0;
  reg [WIDTH-1:0] r_Wr_Data = 0;
  wire [WIDTH-1:0] w_Rd_Data;
  
  always #10 r_Clk <= !r_Clk; // create oscillating clock

  RAM_1Port #(.WIDTH(WIDTH), .DEPTH(DEPTH)) UUT 
  (.i_Clk(r_Clk),
  .i_WE(r_WE),
  .i_Addr(r_Addr),
  .i_Wr_Data(r_Wr_Data),
  .o_Rd_Data(w_Rd_Data)
  );

  initial
  begin 
    $dumpfile("dump.vcd"); $dumpvars; // for EDA Playground sim
    
    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to start

    // Fill memory with incrementing pattern
    repeat(DEPTH)
    begin
      r_WE <= 1'b1;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1;
      r_Addr    <= r_Addr + 1;
    end

    // Read out incrementing pattern
    r_Addr  <= 0;
    r_WE <= 1'b0;
    
    repeat(DEPTH)
    begin
      @(posedge r_Clk);
      r_Addr <= r_Addr + 1;
	  end

    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to end

    $finish();
  end

endmodule
