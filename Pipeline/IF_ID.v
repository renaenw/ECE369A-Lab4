`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 01:37:52 AM
// Design Name: 
// Module Name: IF_ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF_ID(
    input Clk, Reset,
    input [31:0] PCResultIn, PCAddResultIn, InstructionIn,
    output reg [31:0] PCResultOut, PCAddResultOut, InstructionOut);
    
    always @(posedge Clk) begin
        if (Reset)
            {PCResultOut, PCAddResultOut, InstructionOut} <= 0;
        else
            {PCResultOut, PCAddResultOut, InstructionOut} <= {PCResultIn, PCAddResultIn, InstructionIn};
    end
endmodule
