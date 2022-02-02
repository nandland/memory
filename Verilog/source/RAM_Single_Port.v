// Russell Merrick - http://www.nandland.com
//
// Creates a Single Port RAM. 
// Single port RAM which can only read or write, not both on the same clock
// Dual port RAM can read and write on both ports simultaneously.
//
// WIDTH sets the width of the Memory created.
// DEPTH sets the depth of the Memory created.
// Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
// If small, tools will infer register-based memory.

module RAM_Single_Port #(parameter WIDTH = 16,
                         parameter DEPTH = 256)
  (
   input                     i_Clk,
   input                     i_Wr_En,
   input [$clog2(DEPTH)-1:0] i_Addr,
   input [WIDTH-1:0]         i_Wr_Data,
   output reg [WIDTH-1:0]    o_Rd_Data,
   );
  
  reg [WIDTH-1:0] r_Mem [DEPTH-1:0];

  always @(posedge i_Clk)
  begin
    if (i_Wr_En)
      r_Mem[i_Addr] = #1 i_Wr_Data;
  end

  assign o_Rd_Data = r_Mem[i_Addr];

endmodule
