`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 100%
//
// Module - EX_MEM_Reg.v
// Description - EX/MEM pipeline register. Branch signals are not carried
//               (branches and jumps are resolved in ID).
//////////////////////////////////////////////////////////////////////////////////


module EX_MEM(
    input Clk, Reset,
 
    // control signals
    input RegWriteIn, MemtoRegIn, MemReadIn, MemWriteIn,
    input [1:0] MemSizeIn,
 
    // data
    input [31:0] PCResultIn, ALUResultIn, MemWriteDataIn,
    input [4:0] WriteRegisterIn,
    
    output reg RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut,
    output reg [1:0] MemSizeOut,
    output reg [31:0] PCResultOut, ALUResultOut, MemWriteDataOut,
    output reg [4:0] WriteRegisterOut);
 
    always @(posedge Clk) begin
        if (Reset)
            {RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, MemSizeOut,
            PCResultOut, ALUResultOut, MemWriteDataOut, WriteRegisterOut} <= 0;
        else
            {RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, MemSizeOut,
            PCResultOut, ALUResultOut, MemWriteDataOut, WriteRegisterOut}
            <=
            {RegWriteIn, MemtoRegIn, MemReadIn, MemWriteIn, MemSizeIn,
            PCResultIn, ALUResultIn, MemWriteDataIn, WriteRegisterIn};
    end
endmodule
