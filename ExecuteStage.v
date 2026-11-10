`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Thomas Shing 100%
//
// Module - ExecuteStage.v
// Description - Everything between the ID/EX and EX/MEM pipeline registers.
//               Instantiate this once in the top module.
//
//   - ALU A mux   : rs value, or shamt (Immediate[10:6]) for sll/srl
//   - ALU B mux   : rt value, or the immediate (sign or zero extended)
//   - ALU
//   - RegDst mux  : rt, rd or $ra (31)
//   - Link mux    : jal writes PC+8 to $ra through the ALU result path
//
//   Branches and jumps are resolved in the ID stage (see Datapath.v), so
//   there is no branch adder or branch comparator here.
//
// INPUTS (from ID/EX):-
// PCPlus4      : 32-Bit PC + 4 of this instruction
// ReadData1    : 32-Bit rs value
// ReadData2    : 32-Bit rt value
// Immediate    : 32-Bit sign extended Instruction[15:0]. Bits [10:6] are the
//                shamt field, so no separate shamt pipeline field is needed.
// Rt, Rd       : 5-Bit Instruction[20:16] and Instruction[15:11]
// ALUControl, ALUSrc, ShiftSrc, ZeroExt, RegDst, Link : from
//                Controller.v (see that file for encodings)
//
// OUTPUTS (to EX/MEM):-
// ALUResult    : 32-Bit result (PC+8 for jal, memory address for loads/stores)
// Zero         : ALU zero flag
// WriteRegister: 5-Bit destination register
// MemWriteData : 32-Bit rt value, the data stored by sw/sh/sb
////////////////////////////////////////////////////////////////////////////////

module ExecuteStage(PCPlus4, ReadData1, ReadData2, Immediate, Rt, Rd,
                    ALUControl, ALUSrc, ShiftSrc, ZeroExt, RegDst, Link,
                    ALUResult, Zero, WriteRegister, MemWriteData);

    input [31:0] PCPlus4, ReadData1, ReadData2, Immediate;
    input [4:0] Rt, Rd;
    input [3:0] ALUControl;
    input ALUSrc, ShiftSrc, ZeroExt, Link;
    input [1:0] RegDst;

    output [31:0] ALUResult;
    output Zero;
    output reg [4:0] WriteRegister;
    output [31:0] MemWriteData;

    wire [31:0] ImmOperand, ALUInA, ALUInB, ALUOut;

    assign ImmOperand = ZeroExt ? {16'd0, Immediate[15:0]} : Immediate;

    assign ALUInA = ShiftSrc ? {27'd0, Immediate[10:6]} : ReadData1;
    assign ALUInB = ALUSrc ? ImmOperand : ReadData2;

    ALU32Bit alu(
        .ALUControl(ALUControl),
        .A(ALUInA),
        .B(ALUInB),
        .ALUResult(ALUOut),
        .Zero(Zero)
    );

    assign ALUResult = Link ? (PCPlus4 + 32'd4) : ALUOut;

    assign MemWriteData = ReadData2;

    always @(*) begin
        case (RegDst)
            2'b00: WriteRegister = Rt;
            2'b01: WriteRegister = Rd;
            2'b10: WriteRegister = 5'd31;
            default: WriteRegister = Rt;
        endcase
    end

endmodule
