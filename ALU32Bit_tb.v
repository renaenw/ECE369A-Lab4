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
	   A = 12; B = 10; ALUControl = 0; #10; $display("AND: %d (expect 8)", ALUResult);
	   A = 12; B = 10; ALUControl = 1; #10; $display("OR: %d (expect 14)", ALUResult);
	   A = 10; B = 20; ALUControl = 2; #10; $display("ADD: %d (expect 30)", ALUResult);
	   A = 4;  B = 1;  ALUControl = 3; #10; $display("SLL: %d (expect 16, B << A)", ALUResult);
       A = 2;  B = 16; ALUControl = 4; #10; $display("SRL: %d (expect 4, B >> A)", ALUResult);
       A = 30; B = 12; ALUControl = 5; #10; $display("SUB: %d (expect 18)", ALUResult);
       A = 2;  B = 5;  ALUControl = 6; #10; $display("SLT: %d (expect 1)", ALUResult);
       A = -5; B = 3;  ALUControl = 6; #10; $display("SLT signed: %d (expect 1)", ALUResult);
       A = 3;  B = -5; ALUControl = 6; #10; $display("SLT signed: %d (expect 0)", ALUResult);
       A = 0;  B = 0;  ALUControl = 7; #10; $display("NOR: %h (expect ffffffff)", ALUResult);
       A = 15; B = 9;  ALUControl = 8; #10; $display("XOR: %d (expect 6)", ALUResult);
       A = 6;  B = 7;  ALUControl = 9; #10; $display("MUL: %d (expect 42)", ALUResult);
       A = -3; B = 7;  ALUControl = 9; #10; $display("MUL signed: %0d (expect -21)", $signed(ALUResult));
       A = 5;  B = 5;  ALUControl = 5; #10; $display("Zero check: %b (expect 1)", Zero);
       $finish;
	end

endmodule
