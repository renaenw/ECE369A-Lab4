`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 100%
//
// Module - IF_ID_Reg.v
// Description - IF/ID pipeline register.
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
