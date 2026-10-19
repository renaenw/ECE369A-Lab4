`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Thomas Shing 100%
// Module - DataMemory_tb.v
// Description - Test the 'DataMemory.v' module.
////////////////////////////////////////////////////////////////////////////////

module DataMemory_tb(); 

    reg     [31:0]  Address;
    reg     [31:0]  WriteData;
    reg             Clk;
    reg             MemWrite;
    reg             MemRead;

    wire [31:0] ReadData;

    DataMemory u0(
        .Address(Address), 
        .WriteData(WriteData), 
        .Clk(Clk), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ReadData(ReadData)
    ); 

	initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end

	initial begin
	
    /* Please fill in the implementation here... */
    MemWrite = 0; MemRead = 0;
        Address = 0; WriteData = 0;

        //Test 1: Basic write then read back
        @(posedge Clk); #1;
        Address = 32'h00000004; WriteData = 32'hDEADBEEF;
        MemWrite = 1; MemRead = 0;
        @(posedge Clk); #1;       
        MemWrite = 0; MemRead = 1;
        #1;


        //Test 2: MemRead=0 forces ReadData to 0
        MemRead = 0; #1;

        //Test 3: Write and read address 0
        MemRead = 0;
        Address = 32'h00000000; WriteData = 32'hCAFEBABE;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0; MemRead = 1; #1;


        //Test 4: Write and read last valid address (word 1023 = byte 0xFFC)
        MemRead = 0;
        Address = 32'h00000FFC; WriteData = 32'h12345678;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0; MemRead = 1; #1;

        //Test 5: Multiple locations do not alias each other
        MemRead = 0;
        Address = 32'h00000008; WriteData = 32'hAAAAAAAA;
        MemWrite = 1;
        @(posedge Clk); #1;
        Address = 32'h0000000C; WriteData = 32'hBBBBBBBB;
        @(posedge Clk); #1;
        MemWrite = 0; MemRead = 1;
        Address = 32'h00000008; #1;

        Address = 32'h0000000C; #1;


        //Test 6: MemWrite=0 must not overwrite existing data
        MemRead = 0;
        Address = 32'h00000004; WriteData = 32'h00000000;
        MemWrite = 0;
        @(posedge Clk); #1;     
        MemRead = 1; #1;


        //Test 7: Address bits [1:0] are ignored (byte-within-word bits)
        MemRead = 0;
        Address = 32'h00000010; WriteData = 32'hFEEDFACE;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0; MemRead = 1;
        //All four byte addresses in word 4 (0x10, 0x11, 0x12, 0x13) should read the same
        Address = 32'h00000010; #1;

        Address = 32'h00000013; #1;

        //Test 8: Overwrite an existing location
        MemRead = 0;
        Address = 32'h00000004; WriteData = 32'hC0FFEE00;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0; MemRead = 1; #1;
        #20;
        $finish;
	
	end

endmodule

