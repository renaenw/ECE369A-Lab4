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
//   - Branch adder: BranchTarget = PC+4 + (sign extended offset << 2)
//   - Branch check: BranchCond for beq/bne/bgez/bgtz/blez/bltz
//   - RegDst mux  : rt, rd or $ra (31)
//   - Link mux    : jal writes PC+8 to $ra through the ALU result path
//
// INPUTS (from ID/EX):-
// PCPlus4      : 32-Bit PC + 4 of this instruction
// ReadData1    : 32-Bit rs value
// ReadData2    : 32-Bit rt value
// Immediate    : 32-Bit sign extended Instruction[15:0]. Bits [10:6] are the
//                shamt field, so no separate shamt pipeline field is needed.
// Rt, Rd       : 5-Bit Instruction[20:16] and Instruction[15:11]
// ALUControl, ALUSrc, ShiftSrc, ZeroExt, RegDst, Link, BranchType : from
//                Controller.v (see that file for encodings)
//
// OUTPUTS (to EX/MEM):-
// ALUResult    : 32-Bit result (PC+8 for jal, memory address for loads/stores)
// Zero         : ALU zero flag
// BranchTarget : 32-Bit branch target address
// BranchCond   : 1 if the branch condition is true. The MEM stage takes the
//                branch when (Branch & BranchCond).
// WriteRegister: 5-Bit destination register
// MemWriteData : 32-Bit rt value, the data stored by sw/sh/sb
////////////////////////////////////////////////////////////////////////////////

module ExecuteStage(PCPlus4, ReadData1, ReadData2, Immediate, Rt, Rd,
                    ALUControl, ALUSrc, ShiftSrc, ZeroExt, RegDst, Link, BranchType,
                    ALUResult, Zero, BranchTarget, BranchCond, WriteRegister, MemWriteData);

    input [31:0] PCPlus4, ReadData1, ReadData2, Immediate;
    input [4:0] Rt, Rd;
    input [3:0] ALUControl;
    input ALUSrc, ShiftSrc, ZeroExt, Link;
    input [1:0] RegDst;
    input [2:0] BranchType;

    output [31:0] ALUResult;
    output Zero;
    output [31:0] BranchTarget;
    output reg BranchCond;
    output reg [4:0] WriteRegister;
    output [31:0] MemWriteData;

    wire [31:0] ImmOperand, ALUInA, ALUInB, ALUOut;

    // andi/ori/xori zero extend; everything else uses the sign extended value
    assign ImmOperand = ZeroExt ? {16'd0, Immediate[15:0]} : Immediate;

    // shamt path: shifts take their amount from Instruction[10:6]
    assign ALUInA = ShiftSrc ? {27'd0, Immediate[10:6]} : ReadData1;
    assign ALUInB = ALUSrc ? ImmOperand : ReadData2;

    ALU32Bit alu(
        .ALUControl(ALUControl),
        .A(ALUInA),
        .B(ALUInB),
        .ALUResult(ALUOut),
        .Zero(Zero)
    );

    // jal: return address PC+8 (MIPS reference, see Common Questions Q9)
    assign ALUResult = Link ? (PCPlus4 + 32'd4) : ALUOut;

    assign BranchTarget = PCPlus4 + {Immediate[29:0], 2'b00};

    assign MemWriteData = ReadData2;

    // Branch conditions (BranchType encoding from Controller.v)
    always @(*) begin
        case (BranchType)
            3'd0: BranchCond = (ReadData1 == ReadData2);      // beq
            3'd1: BranchCond = (ReadData1 != ReadData2);      // bne
            3'd2: BranchCond = ~ReadData1[31];                // bgez: rs >= 0
            3'd3: BranchCond = ~ReadData1[31] & (ReadData1 != 32'd0); // bgtz: rs > 0
            3'd4: BranchCond = ReadData1[31] | (ReadData1 == 32'd0);  // blez: rs <= 0
            3'd5: BranchCond = ReadData1[31];                 // bltz: rs < 0
            default: BranchCond = 1'b0;
        endcase
    end

    // RegDst mux: 00 rt, 01 rd, 10 $ra
    always @(*) begin
        case (RegDst)
            2'b00: WriteRegister = Rt;
            2'b01: WriteRegister = Rd;
            2'b10: WriteRegister = 5'd31;
            default: WriteRegister = Rt;
        endcase
    end

endmodule
