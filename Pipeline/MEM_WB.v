`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova
//
// Module - MEM_WB_Reg.v
// Description - MEM/WB pipeline register.
//////////////////////////////////////////////////////////////////////////////////


module MEM_WB(
    input Clk, Reset,
    input RegWriteIn, MemtoRegIn,
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
