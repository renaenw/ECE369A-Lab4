`timescale 1ns / 1ps
 
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 100%
//
// Module - Datapath_tb.v
// Description - Runs Tests/instruction_memory.mem and prints every value
//               written to the register file. Expected:
//               PC=0 -> 6, PC=24 -> 10, PC=48 -> 16, PC=96 -> 16, PC=120 -> 4
//               (sw at PC=72 writes no register; lw at PC=96 shows it worked)
////////////////////////////////////////////////////////////////////////////////
 
module Datapath_tb();
    reg Clk = 0, Reset = 1;
    wire [31:0] PC, WriteData;
 
    Datapath uut(.Clk(Clk), .Reset(Reset), .PC(PC), .WriteData(WriteData));
 
    always #10 Clk = ~Clk;
    initial begin
        #35 Reset = 0;      // hold reset 1.5+ cycles, release between clock edges
        #500 $finish;
    end
 
    always @(negedge Clk)
        if (uut.WB_RegWrite)
            $display("PC=%0d  WriteData=%0d", PC, WriteData);
endmodule
