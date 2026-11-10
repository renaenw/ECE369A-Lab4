`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 100%
//
// Module - IF_ID_Reg.v
// Description - IF/ID pipeline register.
//
// Lab 6 - Hazard Detection:
// Added Stall input to hold the current instruction and PC values
// when a register dependency is detected.
//////////////////////////////////////////////////////////////////////////////////


module IF_ID(
    input Clk, Reset, Stall, Flush,
    input [31:0] PCResultIn, PCAddResultIn, InstructionIn,
    output reg [31:0] PCResultOut, PCAddResultOut, InstructionOut);
    
    always @(posedge Clk) begin
        if (Reset || Flush)
            {PCResultOut, PCAddResultOut, InstructionOut} <= 0;
        else if (!Stall)
            {PCResultOut, PCAddResultOut, InstructionOut} <= {PCResultIn, PCAddResultIn, InstructionIn};
    end
endmodule
