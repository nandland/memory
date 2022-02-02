// Russell Merrick - http://www.nandland.com
//
// Creates a Dual Port RAM. 
// Allows for reading and writing simultaneously
// as opposed to a single port RAM which can only do one or the other.
//
// WIDTH sets the width of the Memory created.
// DEPTH sets the depth of the Memory created.
// Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
// If small, tools will infer register-based memory.
// 
// Uses a single clock for both ports.

module RAM_Dual_Port_Single_Clock #(parameter WIDTH = 8, DEPTH = 256)
  (input                     i_Clk,
   // Port A Signals
   input [WIDTH-1:0]         i_PortA_Data,
   input [$clog2(DEPTH)-1:0] i_PortA_Addr,
   input                     i_PortA_WE,
   output reg [WIDTH-1:0]    o_PortA_Data,
   // Port B Signals
   input [WIDTH-1:0]         i_PortB_Data,
   input [$clog2(DEPTH)-1:0] i_PortB_Addr,
   input                     i_PortB_WE,
   output reg [WIDTH-1:0]    o_PortB_Data
   );

  // Declare the Memory variable
  reg [WIDTH-1:0] r_Memory[DEPTH-1:0];
	
  // Port A
  always @ (posedge i_Clk)
  begin
    if (i_PortA_WE) 
    begin
      r_Memory[i_PortA_Addr] <= i_PortA_Data;
      o_PortA_Data           <= i_PortA_Data;
    end
    else 
    begin
      o_PortA_Data <= r_Memory[i_PortA_Addr];
    end
  end
	
  // Port B
  always @ (posedge i_Clk)
  begin
    if (i_PortB_WE)
    begin
      r_Memory[i_PortB_Addr] <= i_PortB_Data;
      o_PortB_Data           <= i_PortB_Data;
    end
    else
    begin
      o_PortB_Data <= r_Memory[i_PortB_Addr];
    end
  end
	
endmodule
