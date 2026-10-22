
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Lab 4
// Module: Controller_tb.v
// Description: Testbench for the pipelined MIPS Controller.
// Tests arithmetic, memory, branch, jump, and NOP instructions.
////////////////////////////////////////////////////////////////////////////////

module Controller_tb;

    // Input
    reg [31:0] Instruction;

    // Controller outputs
    wire RegWrite, MemtoReg;
    wire MemRead, MemWrite;
    wire [1:0] MemSize;
    wire Branch;
    wire [2:0] BranchType;
    wire Jump, JumpReg;
    wire [1:0] RegDst;
    wire ALUSrc, ShiftSrc, ZeroExt, Link;
    wire [3:0] ALUControl;

    // Test counters
    integer passed = 0;
    integer failed = 0;

    // Instantiate Controller
    Controller uut (
        .Instruction(Instruction),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemSize(MemSize),
        .Branch(Branch),
        .BranchType(BranchType),
        .Jump(Jump),
        .JumpReg(JumpReg),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .ShiftSrc(ShiftSrc),
        .ZeroExt(ZeroExt),
        .Link(Link),
        .ALUControl(ALUControl)
    );

    // Combine all outputs so every control signal is checked.
    wire [21:0] ActualSignals = {
        RegWrite, MemtoReg, MemRead, MemWrite,
        MemSize, Branch, BranchType, Jump, JumpReg,
        RegDst, ALUSrc, ShiftSrc, ZeroExt, Link, ALUControl
    };

    // Check the Controller output for an instruction.
    task checkInstruction;
        input [31:0] instructionValue;
        input [21:0] expectedSignals;
        input [127:0] testName;
        begin
            Instruction = instructionValue;
            #10;

            if (ActualSignals === expectedSignals) begin
                $display("PASS: %0s", testName);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s", testName);
                $display("  Instruction: %h", Instruction);
                $display("  Expected: %h", expectedSignals);
                $display("  Actual:   %h", ActualSignals);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        // Test 1: NOP - no register or memory write
        checkInstruction(32'h00000000,
            {4'b0000, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b01, 4'b0100, 4'd3},
            "NOP");

        // Test 2: ADD - R-type arithmetic
        checkInstruction(32'h00221820,
            {4'b1000, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b01, 4'b0000, 4'd2},
            "ADD");

        // Test 3: SUB - R-type arithmetic
        checkInstruction(32'h00221822,
            {4'b1000, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b01, 4'b0000, 4'd5},
            "SUB");

        // Test 4: ADDI - immediate arithmetic
        checkInstruction(32'h20220005,
            {4'b1000, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "ADDI");

        // Test 5: ANDI - zero-extended immediate
        checkInstruction(32'h302200FF,
            {4'b1000, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1010, 4'd0},
            "ANDI");

        // Test 6: LW - load word
        checkInstruction(32'h8C220004,
            {4'b1110, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "LW");

        // Test 7: SW - store word
        checkInstruction(32'hAC220004,
            {4'b0001, 2'b00, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "SW");

        // Test 8: LH - load halfword
        checkInstruction(32'h84220004,
            {4'b1110, 2'b01, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "LH");

        // Test 9: SH - store halfword
        checkInstruction(32'hA4220004,
            {4'b0001, 2'b01, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "SH");

        // Test 10: LB - load byte
        checkInstruction(32'h80220004,
            {4'b1110, 2'b10, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "LB");

        // Test 11: SB - store byte
        checkInstruction(32'hA0220004,
            {4'b0001, 2'b10, 1'b0, 3'b000, 2'b00,
             2'b00, 4'b1000, 4'd2},
            "SB");

        // Test 12: BEQ - branch equal
        checkInstruction(32'h10220003,
            {4'b0000, 2'b00, 1'b1, 3'b000, 2'b00,
             2'b00, 4'b0000, 4'd5},
            "BEQ");

        // Test 13: BNE - branch not equal
        checkInstruction(32'h14220003,
            {4'b0000, 2'b00, 1'b1, 3'b001, 2'b00,
             2'b00, 4'b0000, 4'd5},
            "BNE");

        // Test 14: BGTZ - branch greater than zero
        checkInstruction(32'h1C200003,
            {4'b0000, 2'b00, 1'b1, 3'b011, 2'b00,
             2'b00, 4'b0000, 4'd2},
            "BGTZ");

        // Test 15: J - jump
        checkInstruction(32'h08000004,
            {4'b0000, 2'b00, 1'b0, 3'b000, 2'b10,
             2'b00, 4'b0000, 4'd2},
            "J");

        // Test 16: JAL - jump and link
        checkInstruction(32'h0C000004,
            {4'b1000, 2'b00, 1'b0, 3'b000, 2'b10,
             2'b10, 4'b0001, 4'd2},
            "JAL");

        // Test 17: JR - jump register
        checkInstruction(32'h00200008,
            {4'b0000, 2'b00, 1'b0, 3'b000, 2'b01,
             2'b00, 4'b0000, 4'd2},
            "JR");

        $display("");
        $display("==================================");
        $display(" CONTROLLER TEST RESULTS");
        $display(" Passed: %0d", passed);
        $display(" Failed: %0d", failed);
        $display("==================================");

        if (failed == 0)
            $display("ALL CONTROLLER TESTS PASSED!");
        else
            $display("CONTROLLER TESTS NEED REVIEW.");

        $finish;
    end

endmodule
