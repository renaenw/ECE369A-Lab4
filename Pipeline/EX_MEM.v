`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova
//
// Module - EX_MEM_Reg.v
// Description - EX/MEM pipeline register.
//////////////////////////////////////////////////////////////////////////////////


module EX_MEM_Reg(
    input Clk, Reset,
 
    // control signals
    input RegWriteIn, MemtoRegIn, MemReadIn, MemWriteIn, BranchIn,
    input [1:0] MemSizeIn,
 
    // data
    input [31:0] PCResultIn, ALUResultIn, BranchTargetIn, MemWriteDataIn,
    input BranchCondIn,
    input [4:0] WriteRegisterIn,
    
    output reg RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, BranchOut,
    output reg [1:0] MemSizeOut,
    output reg [31:0] PCResultOut, ALUResultOut, BranchTargetOut, MemWriteDataOut,
    output reg BranchCondOut,
    output reg [4:0] WriteRegisterOut);
 
    always @(posedge Clk) begin
        if (Reset)
            {RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, BranchOut, MemSizeOut,
            PCResultOut, ALUResultOut, BranchTargetOut, MemWriteDataOut, BranchCondOut, WriteRegisterOut} <= 0;
        else
            {RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, BranchOut, MemSizeOut,
            PCResultOut, ALUResultOut, BranchTargetOut, MemWriteDataOut, BranchCondOut, WriteRegisterOut}
            <=
            {RegWriteIn, MemtoRegIn, MemReadIn, MemWriteIn, BranchIn, MemSizeIn,
            PCResultIn, ALUResultIn, BranchTargetIn, MemWriteDataIn, BranchCondIn, WriteRegisterIn};
    end
endmodule
