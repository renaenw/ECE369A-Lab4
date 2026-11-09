`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 100%
//
// Module - ID_EX_Reg.v
// Description - ID/EX pipeline register.
//
// Lab 6 - Hazard Detection:
// Added Stall input to insert a bubble into the EX stage when
// a register dependency is detected.
//////////////////////////////////////////////////////////////////////////////////


module ID_EX(
    input Clk, Reset, Stall,
 
    // control signals from the Controller
    input RegWriteIn, MemtoRegIn, MemReadIn, MemWriteIn, BranchIn, ALUSrcIn, ShiftSrcIn, ZeroExtIn, LinkIn,
    input [1:0] MemSizeIn, RegDstIn,
    input [2:0] BranchTypeIn,
    input [3:0] ALUControlIn,
 
    // data
    input [31:0] PCResultIn, PCPlus4In, ReadData1In, ReadData2In, ImmediateIn,
    input [4:0] RtIn, RdIn,

    output reg RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, BranchOut, ALUSrcOut, ShiftSrcOut, ZeroExtOut, LinkOut,
    output reg [1:0] MemSizeOut, RegDstOut,
    output reg [2:0] BranchTypeOut,
    output reg [3:0] ALUControlOut,
    output reg [31:0] PCResultOut, PCPlus4Out, ReadData1Out, ReadData2Out, ImmediateOut,
    output reg [4:0] RtOut, RdOut);
 
    always @(posedge Clk) begin
        if (Reset || Stall)
            {RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, BranchOut, ALUSrcOut, ShiftSrcOut, ZeroExtOut, LinkOut,
             MemSizeOut, RegDstOut, BranchTypeOut, ALUControlOut,
             PCResultOut, PCPlus4Out, ReadData1Out, ReadData2Out, ImmediateOut, RtOut, RdOut} <= 0;
        else
            {RegWriteOut, MemtoRegOut, MemReadOut, MemWriteOut, BranchOut, ALUSrcOut, ShiftSrcOut, ZeroExtOut, LinkOut,
             MemSizeOut, RegDstOut, BranchTypeOut, ALUControlOut,
             PCResultOut, PCPlus4Out, ReadData1Out, ReadData2Out, ImmediateOut, RtOut, RdOut}
             <=
             {RegWriteIn, MemtoRegIn, MemReadIn, MemWriteIn, BranchIn, ALUSrcIn, ShiftSrcIn, ZeroExtIn, LinkIn,
             MemSizeIn, RegDstIn, BranchTypeIn, ALUControlIn, PCResultIn, PCPlus4In, ReadData1In, ReadData2In, 
             ImmediateIn, RtIn, RdIn};
    end
endmodule