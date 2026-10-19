        `timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
// Karyna Kuzhelnykova 100%
//
// INPUTS:-
// ALUControl: N-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
// Design a 32-Bit ALU, so that it supports all arithmetic operations 
// needed by the MIPS instructions given in Labs5-8.docx document. 
//   The 'ALUResult' will output the corresponding result of the operation 
//   based on the 32-Bit inputs, 'A', and 'B'. 
//   The 'Zero' flag is high when 'ALUResult' is '0'. 
//   The 'ALUControl' signal should determine the function of the ALU 
//   You need to determine the bitwidth of the ALUControl signal based on the number of 
//   operations needed to support. 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, ALUResult, Zero);

	input [3:0] ALUControl; // control bits for ALU operation
                                // you need to adjust the bitwidth as needed
	input [31:0] A, B;	    // inputs

	output [31:0] ALUResult;	// answer
	output Zero;	    // Zero=1 if ALUResult == 0

    /* Please fill in the implementation here... */
    // ALU result
    reg[31:0] ALUResult;
    
    // 0=AND 1=OR 2=ADD 3=SLL 4=SRL 5=SUB 6=SLT 7=NOR 8=XOR 9=MUL
    always @(*) begin 
        case (ALUControl)
            4'd0: ALUResult = A & B;
            4'd1: ALUResult = A | B;
            4'd2: ALUResult = A + B;
            4'd3: ALUResult = A << B;
            4'd4: ALUResult = A >> B;
            4'd5: ALUResult = A - B;
            4'd6: ALUResult = (A < B) ? 1 : 0;
            4'd7: ALUResult = ~(A | B);
            4'd8: ALUResult = A ^ B;
            4'd9: ALUResult = A * B;
        endcase
     end
     
     assign Zero = (ALUResult == 0);
endmodule

