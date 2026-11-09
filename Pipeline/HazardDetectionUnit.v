`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Lab 6
// Person A - Hazard Detection Unit
//
// Detects register dependencies and stalls the pipeline until the
// required register value is available.
////////////////////////////////////////////////////////////////////////////////

module HazardDetectionUnit(
    input [31:0] ID_Instruction,
    input EX_RegWrite,
    input [4:0] EX_WriteRegister,
    input MEM_RegWrite,
    input [4:0] MEM_WriteRegister,
    input WB_RegWrite,
    input [4:0] WB_WriteRegister,
    output reg Stall
);

    wire [5:0] opcode = ID_Instruction[31:26];
    wire [5:0] funct  = ID_Instruction[5:0];

    wire [4:0] rs = ID_Instruction[25:21];
    wire [4:0] rt = ID_Instruction[20:16];

    reg uses_rs;
    reg uses_rt;

    always @(*) begin
        uses_rs = 1'b0;
        uses_rt = 1'b0;

        case (opcode)
            6'b000000: begin
                // R-type operations
                case (funct)
                    6'b000000, 6'b000010, 6'b000011:
                        uses_rt = 1'b1; // shifts
                    6'b001000:
                        uses_rs = 1'b1; // jr
                    default: begin
                        uses_rs = 1'b1;
                        uses_rt = 1'b1;
                    end
                endcase
            end

            6'b000010, 6'b000011: begin
                // j and jal
            end

            6'b000100, 6'b000101: begin
                uses_rs = 1'b1;
                uses_rt = 1'b1; // beq, bne
            end

            6'b000111: uses_rs = 1'b1; // bgtz

            6'b101011, 6'b101000, 6'b101001: begin
                uses_rs = 1'b1;
                uses_rt = 1'b1; // sw, sb, sh
            end

            default: uses_rs = 1'b1;
            // Immediate arithmetic and loads use rs only
        endcase
    end

    always @(*) begin
        Stall = 1'b0;

        if (uses_rs && rs != 5'd0) begin
            if ((EX_RegWrite && EX_WriteRegister == rs && EX_WriteRegister != 0) ||
                (MEM_RegWrite && MEM_WriteRegister == rs && MEM_WriteRegister != 0) ||
                (WB_RegWrite && WB_WriteRegister == rs && WB_WriteRegister != 0))
                Stall = 1'b1;
        end

        if (uses_rt && rt != 5'd0) begin
            if ((EX_RegWrite && EX_WriteRegister == rt && EX_WriteRegister != 0) ||
                (MEM_RegWrite && MEM_WriteRegister == rt && MEM_WriteRegister != 0) ||
                (WB_RegWrite && WB_WriteRegister == rt && WB_WriteRegister != 0))
                Stall = 1'b1;
        end
    end

endmodule

