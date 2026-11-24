`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
//
//
// Student(s) Name and Last Name: FILL IN YOUR INFO HERE!
// Renae Weiss 100%
//
// Module - register_file.v
// Description - Implements a register file with 32 32-Bit wide registers.
//
// 
// INPUTS:-
// ReadRegister1: 5-Bit address to select a register to be read through 32-Bit 
//                output port 'ReadRegister1'.
// ReadRegister2: 5-Bit address to select a register to be read through 32-Bit 
//                output port 'ReadRegister2'.
// WriteRegister: 5-Bit address to select a register to be written through 32-Bit
//                input port 'WriteRegister'.
// WriteData: 32-Bit write input port.
// RegWrite: 1-Bit control input signal.
//
// OUTPUTS:-
// ReadData1: 32-Bit registered output. 
// ReadData2: 32-Bit registered output. 
//
// FUNCTIONALITY:-
// 'ReadRegister1' and 'ReadRegister2' are two 5-bit addresses to read two 
// registers simultaneously. The two 32-bit data sets are available on ports 
// 'ReadData1' and 'ReadData2', respectively. 'ReadData1' and 'ReadData2' are 
// registered outputs (output of register file is written into these registers 
// at the falling edge of the clock). You can view it as if outputs of registers
// specified by ReadRegister1 and ReadRegister2 are written into output 
// registers ReadData1 and ReadData2 at the falling edge of the clock. 
//
// 'RegWrite' signal is high during the rising edge of the clock if the input 
// data is to be written into the register file. The contents of the register 
// specified by address 'WriteRegister' in the register file are modified at the 
// rising edge of the clock if 'RegWrite' signal is high. The D-flip flops in 
// the register file are positive-edge (rising-edge) triggered. (You have to use 
// this information to generate the write-clock properly.) 
//
// NOTE:-
// We will design the register file such that the contents of registers do not 
// change for a pre-specified time before the falling edge of the clock arrives 
// to allow for data multiplexing and setup time.
////////////////////////////////////////////////////////////////////////////////

module RegisterFile(ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, Clk, Reset, ReadData1, ReadData2, V0, V1);

    input [4:0] ReadRegister1;
    input [4:0] ReadRegister2;
    input [4:0] WriteRegister;
    input [31:0] WriteData;
    input RegWrite;
    input Clk;
    input Reset;        // Lab 7: synchronous, same Reset as the pipeline registers

    output reg [31:0] ReadData1;
    output reg [31:0] ReadData2;
    output [31:0] V0;   // $v0 (reg 2), for the FPGA display only
    output [31:0] V1;   // $v1 (reg 3), for the FPGA display only

    // 32 registers, each 32 bits wide
    reg [31:0] Registers [0:31];
    
    // Lab 7: $sp starts at the last word of data memory
    // (1024 words = bytes 0..4095, last word at byte 4092 = 0xFFC)
    localparam [31:0] SP_INIT = 32'd4092;

    integer i;
    // Start every register at 0, except $sp
    initial begin
        for (i=0; i<32; i=i+1)
            Registers[i] = 32'd0;
        Registers[29] = SP_INIT;
    end

    // On Reset: clear all registers (so $v0/$v1 show (0,0)) and set $sp.
    // Otherwise write to the selected register on the rising edge of the clock.
    always @(posedge Clk) begin
        if (Reset) begin
            for (i=0; i<32; i=i+1)
                Registers[i] <= 32'd0;
            Registers[29] <= SP_INIT;
        end
        else if (RegWrite && WriteRegister != 5'd0)
            Registers[WriteRegister] <= WriteData;
    end

    // Read two selected registers on the falling edge of the clock
    always @(negedge Clk) begin
        ReadData1 <= Registers[ReadRegister1];
        ReadData2 <= Registers[ReadRegister2];
    end

    // Always-on read taps of $v0 and $v1 for the display (not a new write port)
    assign V0 = Registers[2];
    assign V1 = Registers[3];

endmodule