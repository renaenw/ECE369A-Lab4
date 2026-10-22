`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 02:17:42 AM
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input Clk, Reset,
    input RegWriteIn, ALUResultIn, MemtoRegIn,
    input [31:0] PCResultIn, ALUResultIn, ReadDataIn,
    input [4:0] WriteRegisterIn, 
    
    output reg RegWriteOut, MemtoRegOut,
    output reg [31:0] PCResultOut, ALUResultOut, ReadDataOut,
    output reg [4:0] WriteRegisterOut);
    
    always @(posedge Clk) begin
        if (Reset)
            {RegWriteOut, MemtoRegOut, PCResultOut, ALUResultOut, ReadDataOut, WriteRegisterOut} <= 0;
        else
            {RegWriteOut, MemtoRegOut, PCResultOut, ALUResultOut, ReadDataOut, WriteRegisterOut} 
            <= {RegWriteIn, MemtoRegIn, PCResultIn, ALUResultIn, ReadDataIn, WriteRegisterIn};
    end
endmodule
