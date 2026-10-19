`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit_tb.v
// Description - Test the 'ALU32Bit.v' module.
// Karyna Kuzhelnykova 100%
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit_tb(); 

	reg [3:0] ALUControl;   // control bits for ALU operation
	reg [31:0] A, B;	        // inputs

	wire [31:0] ALUResult;	// answer
	wire Zero;	        // Zero=1 if ALUResult == 0

    ALU32Bit u0(
        .ALUControl(ALUControl), 
        .A(A), 
        .B(B), 
        .ALUResult(ALUResult), 
        .Zero(Zero)
    );

	initial begin
    /* Please fill in the implementation here... */
	   A = 12; B = 10; ALUControl = 0; #10; $display("AND: %d", ALUResult);
	   A = 12; B = 10; ALUControl = 1; #10; $display("OR: %d", ALUResult);
	   A = 10; B = 20; ALUControl = 2; #10; $display("ADD: %d", ALUResult);
	   A = 1;  B = 4;  ALUControl = 3; #10; $display("SLL: %d", ALUResult);
       A = 16; B = 2;  ALUControl = 4; #10; $display("SRL: %d", ALUResult);
       A = 30; B = 12; ALUControl = 5; #10; $display("SUB: %d", ALUResult);
       A = 5;  B = 2;  ALUControl = 6; #10; $display("SLT: %d", ALUResult);
       A = 0;  B = 0;  ALUControl = 7; #10; $display("NOR: %d", ALUResult);
       A = 15; B = 9;  ALUControl = 8; #10; $display("XOR: %d", ALUResult);
       A = 6;  B = 7;  ALUControl = 9; #10; $display("MUL: %d", ALUResult);
       A = 5;  B = 5;  ALUControl = 5; #10; $display("Zero check: %b", Zero);
       $finish;
	end

endmodule

