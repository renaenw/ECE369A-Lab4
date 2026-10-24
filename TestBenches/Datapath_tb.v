`timescale 1ns / 1ps
 
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 100%
//
// Description - Prints the PC and value of every register write.
// branch_jump_test: 5, -3, 160, 1 (no 99)
// basic_test:       6, 10, 16, 16, 4
////////////////////////////////////////////////////////////////////////////////
 
module Datapath_tb();
    reg Clk = 0, Reset = 1;
    wire [31:0] PC, WriteData;
 
    Datapath uut(.Clk(Clk), .Reset(Reset), .PC(PC), .WriteData(WriteData));
 
    always #10 Clk = ~Clk;
    initial begin
        #35 Reset = 0;      // hold reset 1.5+ cycles, release between clock edges
        #1500 $finish;
    end
 
    always @(negedge Clk)
        if (uut.WB_RegWrite)
            $display("PC=%0d  WriteData=%0d", PC, $signed(WriteData));
endmodule
