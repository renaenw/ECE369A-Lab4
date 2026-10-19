`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Thomas Shing 100%
//
// Module - Controller.v
// Description - Main controller for the pipelined datapath. Decodes the
//               opcode, function and rt fields of the instruction in the ID
//               stage and generates every control signal the later stages
//               need. ALU control is also generated here, so the EX stage
//               does not need a separate ALU control block.
//
// INPUTS:-
// Instruction: 32-Bit instruction from the IF/ID register.
//
// OUTPUTS:-
//  WB stage
//   RegWrite   : 1 = write the register file
//   MemtoReg   : 0 = write ALU/EX result, 1 = write data memory output
//  MEM stage
//   MemRead    : 1 = read data memory (lw, lh, lb)
//   MemWrite   : 1 = write data memory (sw, sh, sb)
//   MemSize    : 00 = word, 01 = half word, 10 = byte
//   Branch     : 1 = conditional branch instruction
//   BranchType : 000 beq, 001 bne, 010 bgez, 011 bgtz, 100 blez, 101 bltz
//   Jump       : 1 = j or jal (target = {PC+4[31:28], index, 00})
//   JumpReg    : 1 = jr (target = rs)
//  EX stage
//   RegDst     : 00 = rt, 01 = rd, 10 = $ra (31, for jal)
//   ALUSrc     : 0 = ALU B is rt value, 1 = ALU B is the immediate
//   ShiftSrc   : 1 = ALU A is shamt (sll, srl), 0 = ALU A is rs value
//   ZeroExt    : 1 = zero extend the immediate (andi, ori, xori)
//   Link       : 1 = EX result is the return address PC+8 (jal)
//   ALUControl : 0 AND, 1 OR, 2 ADD, 3 SLL, 4 SRL, 5 SUB, 6 SLT, 7 NOR,
//                8 XOR, 9 MUL (same encoding as ALU32Bit.v)
//
// A nop (all zeros, which is sll $0, $0, 0) sets every signal to 0.
////////////////////////////////////////////////////////////////////////////////

module Controller(Instruction, RegWrite, MemtoReg, MemRead, MemWrite, MemSize,
                  Branch, BranchType, Jump, JumpReg, RegDst, ALUSrc, ShiftSrc,
                  ZeroExt, Link, ALUControl);

    input [31:0] Instruction;

    output reg RegWrite, MemtoReg;
    output reg MemRead, MemWrite;
    output reg [1:0] MemSize;
    output reg Branch;
    output reg [2:0] BranchType;
    output reg Jump, JumpReg;
    output reg [1:0] RegDst;
    output reg ALUSrc, ShiftSrc, ZeroExt, Link;
    output reg [3:0] ALUControl;

    wire [5:0] Opcode = Instruction[31:26];
    wire [5:0] Funct  = Instruction[5:0];
    wire [4:0] Rt     = Instruction[20:16];

    // ALUControl encoding
    localparam ALU_AND = 4'd0, ALU_OR  = 4'd1, ALU_ADD = 4'd2, ALU_SLL = 4'd3,
               ALU_SRL = 4'd4, ALU_SUB = 4'd5, ALU_SLT = 4'd6, ALU_NOR = 4'd7,
               ALU_XOR = 4'd8, ALU_MUL = 4'd9;

    // BranchType encoding
    localparam BR_BEQ = 3'd0, BR_BNE = 3'd1, BR_BGEZ = 3'd2,
               BR_BGTZ = 3'd3, BR_BLEZ = 3'd4, BR_BLTZ = 3'd5;

    // MemSize encoding
    localparam SIZE_WORD = 2'b00, SIZE_HALF = 2'b01, SIZE_BYTE = 2'b10;

    // Opcodes
    localparam OP_RTYPE = 6'b000000, OP_REGIMM = 6'b000001, OP_SPECIAL2 = 6'b011100,
               OP_J     = 6'b000010, OP_JAL    = 6'b000011,
               OP_BEQ   = 6'b000100, OP_BNE    = 6'b000101,
               OP_BLEZ  = 6'b000110, OP_BGTZ   = 6'b000111,
               OP_ADDI  = 6'b001000, OP_SLTI   = 6'b001010,
               OP_ANDI  = 6'b001100, OP_ORI    = 6'b001101, OP_XORI = 6'b001110,
               OP_LB    = 6'b100000, OP_LH     = 6'b100001, OP_LW   = 6'b100011,
               OP_SB    = 6'b101000, OP_SH     = 6'b101001, OP_SW   = 6'b101011;

    // R-type function codes
    localparam FN_SLL = 6'b000000, FN_SRL = 6'b000010, FN_JR  = 6'b001000,
               FN_ADD = 6'b100000, FN_SUB = 6'b100010, FN_AND = 6'b100100,
               FN_OR  = 6'b100101, FN_XOR = 6'b100110, FN_NOR = 6'b100111,
               FN_SLT = 6'b101010;

    // SPECIAL2 function code
    localparam FN_MUL = 6'b000010;

    always @(*) begin
        // Defaults: every output is assigned before the case so no latch is
        // inferred, and anything not decoded below behaves as a nop.
        RegWrite   = 1'b0;
        MemtoReg   = 1'b0;
        MemRead    = 1'b0;
        MemWrite   = 1'b0;
        MemSize    = SIZE_WORD;
        Branch     = 1'b0;
        BranchType = BR_BEQ;
        Jump       = 1'b0;
        JumpReg    = 1'b0;
        RegDst     = 2'b00;
        ALUSrc     = 1'b0;
        ShiftSrc   = 1'b0;
        ZeroExt    = 1'b0;
        Link       = 1'b0;
        ALUControl = ALU_ADD;

        case (Opcode)
            OP_RTYPE: begin
                RegDst = 2'b01;
                case (Funct)
                    FN_ADD: begin RegWrite = 1'b1; ALUControl = ALU_ADD; end
                    FN_SUB: begin RegWrite = 1'b1; ALUControl = ALU_SUB; end
                    FN_AND: begin RegWrite = 1'b1; ALUControl = ALU_AND; end
                    FN_OR:  begin RegWrite = 1'b1; ALUControl = ALU_OR;  end
                    FN_NOR: begin RegWrite = 1'b1; ALUControl = ALU_NOR; end
                    FN_XOR: begin RegWrite = 1'b1; ALUControl = ALU_XOR; end
                    FN_SLT: begin RegWrite = 1'b1; ALUControl = ALU_SLT; end
                    FN_SLL: begin
                        // all-zero instruction is a nop: leave RegWrite at 0
                        RegWrite   = (Instruction != 32'd0);
                        ShiftSrc   = 1'b1;
                        ALUControl = ALU_SLL;
                    end
                    FN_SRL: begin
                        RegWrite   = 1'b1;
                        ShiftSrc   = 1'b1;
                        ALUControl = ALU_SRL;
                    end
                    FN_JR: begin
                        RegDst  = 2'b00;
                        JumpReg = 1'b1;
                    end
                    default: RegDst = 2'b00;
                endcase
            end

            OP_SPECIAL2: begin
                if (Funct == FN_MUL) begin
                    RegWrite   = 1'b1;
                    RegDst     = 2'b01;
                    ALUControl = ALU_MUL;
                end
            end

            // Immediate arithmetic and logical
            OP_ADDI: begin RegWrite = 1'b1; ALUSrc = 1'b1; ALUControl = ALU_ADD; end
            OP_SLTI: begin RegWrite = 1'b1; ALUSrc = 1'b1; ALUControl = ALU_SLT; end
            OP_ANDI: begin RegWrite = 1'b1; ALUSrc = 1'b1; ZeroExt = 1'b1; ALUControl = ALU_AND; end
            OP_ORI:  begin RegWrite = 1'b1; ALUSrc = 1'b1; ZeroExt = 1'b1; ALUControl = ALU_OR;  end
            OP_XORI: begin RegWrite = 1'b1; ALUSrc = 1'b1; ZeroExt = 1'b1; ALUControl = ALU_XOR; end

            // Loads: address = rs + sign extended offset
            OP_LW: begin RegWrite = 1'b1; MemtoReg = 1'b1; MemRead = 1'b1; ALUSrc = 1'b1; MemSize = SIZE_WORD; end
            OP_LH: begin RegWrite = 1'b1; MemtoReg = 1'b1; MemRead = 1'b1; ALUSrc = 1'b1; MemSize = SIZE_HALF; end
            OP_LB: begin RegWrite = 1'b1; MemtoReg = 1'b1; MemRead = 1'b1; ALUSrc = 1'b1; MemSize = SIZE_BYTE; end

            // Stores
            OP_SW: begin MemWrite = 1'b1; ALUSrc = 1'b1; MemSize = SIZE_WORD; end
            OP_SH: begin MemWrite = 1'b1; ALUSrc = 1'b1; MemSize = SIZE_HALF; end
            OP_SB: begin MemWrite = 1'b1; ALUSrc = 1'b1; MemSize = SIZE_BYTE; end

            // Branches: the condition is evaluated in the EX stage
            OP_BEQ:  begin Branch = 1'b1; BranchType = BR_BEQ;  ALUControl = ALU_SUB; end
            OP_BNE:  begin Branch = 1'b1; BranchType = BR_BNE;  ALUControl = ALU_SUB; end
            OP_BGTZ: begin Branch = 1'b1; BranchType = BR_BGTZ; end
            OP_BLEZ: begin Branch = 1'b1; BranchType = BR_BLEZ; end
            OP_REGIMM: begin
                // rt field picks between bgez (00001) and bltz (00000)
                if (Rt == 5'b00001) begin Branch = 1'b1; BranchType = BR_BGEZ; end
                else if (Rt == 5'b00000) begin Branch = 1'b1; BranchType = BR_BLTZ; end
            end

            // Jumps
            OP_J:   Jump = 1'b1;
            OP_JAL: begin
                Jump     = 1'b1;
                Link     = 1'b1;
                RegWrite = 1'b1;
                RegDst   = 2'b10;
            end

            default: ;  // unknown opcode behaves as a nop
        endcase
    end

endmodule
