// Russell Merrick - http://www.nandland.com
//
// Creates a Single Port RAM. 
// Single port RAM has one port, so can only access one memory location at a time.
// Dual port RAM can read and write to different memory locations at the same time.
//
// WIDTH sets the width of the Memory created.
// DEPTH sets the depth of the Memory created.
// Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
// If small, tools will infer register-based memory.

module RAM_1Port #(parameter WIDTH = 16, parameter DEPTH = 256) (
  input                     i_Clk,
  input                     i_WE,
  input [$clog2(DEPTH)-1:0] i_Addr,
  input [WIDTH-1:0]         i_Wr_Data,
  output reg [WIDTH-1:0]    o_Rd_Data
  );
  
  reg [WIDTH-1:0] r_Mem [DEPTH-1:0];

  always @(posedge i_Clk)
  begin
    if (i_WE)
      r_Mem[i_Addr] <= i_Wr_Data; // Handle writes

    o_Rd_Data <= r_Mem[i_Addr];   // Handle Reads (update o_Rd_Data on every clock edge)
  end

endmodule
