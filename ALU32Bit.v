`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
// Karyna Kuzhelnykova 100%
//
// INPUTS:-
// ALUControl: 4-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
//   The 'ALUResult' will output the corresponding result of the operation 
//   based on the 32-Bit inputs, 'A', and 'B'. 
//   The 'Zero' flag is high when 'ALUResult' is '0'. 
//
// Lab 4 changes:
//   - default case added so no latch is inferred
//   - SLT compares signed values (slt/slti are signed in MIPS)
//   - shifts follow MIPS operand order: B (rt) is shifted by A[4:0] (shamt),
//     the Execute stage puts shamt on A for sll/srl
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, ALUResult, Zero);

	input [3:0] ALUControl; // control bits for ALU operation
	input [31:0] A, B;	    // inputs

	output reg [31:0] ALUResult;	// answer
	output Zero;	    // Zero=1 if ALUResult == 0

    // 0=AND 1=OR 2=ADD 3=SLL 4=SRL 5=SUB 6=SLT 7=NOR 8=XOR 9=MUL
    always @(*) begin 
        case (ALUControl)
            4'd0: ALUResult = A & B;
            4'd1: ALUResult = A | B;
            4'd2: ALUResult = A + B;
            4'd3: ALUResult = B << A[4:0];
            4'd4: ALUResult = B >> A[4:0];
            4'd5: ALUResult = A - B;
            4'd6: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            4'd7: ALUResult = ~(A | B);
            4'd8: ALUResult = A ^ B;
            4'd9: ALUResult = A * B;     // low 32 bits, same for signed and unsigned
            default: ALUResult = 32'd0;
        endcase
     end
     
     // kept outside the case block (see Common Questions Q21)
     assign Zero = (ALUResult == 32'd0);
endmodule
