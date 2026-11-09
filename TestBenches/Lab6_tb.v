`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 33.3%
// Thomas Shing 33.3%
// Renae Weiss 33.3%
//
// Module - Lab6_tb.v
// Description - Testbench for the Lab 6 pipelined datapath (hazard detection,
//               branches and jumps resolved in ID with one delay slot).
//
//   Uses only the ports of Datapath (Clk, Reset, PC, WriteData), so it runs
//   in behavioral, post-synthesis and post-route (post-implementation)
//   functional simulation.
//
//   Every cycle in which a register is written (WriteData != 0) prints the
//   PC and the value written, and compares them in order with the expected
//   trace of our test program (Tests/instruction_memory.s). Cycles with
//   WriteData = 0 (stall bubbles, sw, branches, writes of 0) are not checked.
//   After the last expected write the program sits in its "done" loop; the
//   testbench runs EXTRA_CYCLES more to make sure nothing else is written,
//   then prints the cycle count and PASS/FAIL.
//
//   With a different instruction_memory.mem (e.g. the TA's), set CHECK = 0:
//   the trace is still printed, but nothing is compared.
//
//   Expected trace generated from the assembled program by an ISA model with
//   one branch delay slot (jal writes PC + 8).
////////////////////////////////////////////////////////////////////////////////

module Lab6_tb();

    parameter CHECK        = 1;      // 1: compare with the expected trace
    parameter CLK_PERIOD   = 100;    // ns
    parameter MAX_CYCLES   = 2000;   // give up if the program never finishes
    parameter EXTRA_CYCLES = 20;     // cycles watched after the last write

    reg Clk, Reset;
    wire [31:0] PC, WriteData;

    Datapath uut(
        .Clk(Clk),
        .Reset(Reset),
        .PC(PC),
        .WriteData(WriteData)
    );

    integer NumExpected;
    reg [31:0] ExpPC [0:255];
    reg [31:0] ExpData [0:255];

    integer Cycles, Writes, Errors, LastWriteCycle, Extra;

    initial Clk = 1'b0;
    always #(CLK_PERIOD / 2) Clk = ~Clk;

    // expected (PC, WriteData) of every nonzero register write, in order
    initial begin
        NumExpected = 80;
        ExpPC[0] = 0; ExpData[0] = 32'h0000000C;  // 12  addi $t0, $zero, 12
        ExpPC[1] = 4; ExpData[1] = 32'h0000000A;  // 10  addi $t1, $t0, -2
        ExpPC[2] = 8; ExpData[2] = 32'h00000016;  // 22  add $t2, $t0, $t1
        ExpPC[3] = 12; ExpData[3] = 32'h0000000A;  // 10  sub $t3, $t2, $t0
        ExpPC[4] = 16; ExpData[4] = 32'h000000DC;  // 220  mul $t4, $t3, $t2
        ExpPC[5] = 20; ExpData[5] = 32'h000000DE;  // 222  or $t5, $t4, $t1
        ExpPC[6] = 24; ExpData[6] = 32'h000000DC;  // 220  and $t6, $t5, $t4
        ExpPC[7] = 28; ExpData[7] = 32'h00000002;  // 2  xor $t7, $t6, $t5
        ExpPC[8] = 32; ExpData[8] = 32'hFFFFFFFD;  // -3  nor $t8, $t7, $zero
        ExpPC[9] = 36; ExpData[9] = 32'h0000FF0D;  // 65293  andi $t9, $t8, 65295
        ExpPC[10] = 40; ExpData[10] = 32'h0000FFFD;  // 65533  ori $s1, $t9, 240
        ExpPC[11] = 44; ExpData[11] = 32'h0000F0F2;  // 61682  xori $s2, $s1, 3855
        ExpPC[12] = 48; ExpData[12] = 32'h000F0F20;  // 986912  sll $s3, $s2, 4
        ExpPC[13] = 52; ExpData[13] = 32'h00000F0F;  // 3855  srl $s4, $s3, 8
        ExpPC[14] = 56; ExpData[14] = 32'h00000001;  // 1  slt $s5, $t8, $s4
        ExpPC[15] = 60; ExpData[15] = 32'h00000001;  // 1  slti $s6, $s5, 2
        ExpPC[16] = 68; ExpData[16] = 32'h00000001;  // 1  add $v0, $s7, $s6
        ExpPC[17] = 72; ExpData[17] = 32'h00000100;  // 256  addi $s0, $zero, 256
        ExpPC[18] = 80; ExpData[18] = 32'h000000C8;  // 200  addi $a0, $t4, -20
        ExpPC[19] = 88; ExpData[19] = 32'h000000C8;  // 200  lw $a1, 4($s0)
        ExpPC[20] = 92; ExpData[20] = 32'h00000190;  // 400  add $a2, $a1, $a0
        ExpPC[21] = 96; ExpData[21] = 32'h000000DC;  // 220  lw $a3, 0($s0)
        ExpPC[22] = 100; ExpData[22] = 32'h000000B4;  // 180  sub $v1, $a2, $a3
        ExpPC[23] = 104; ExpData[23] = 32'h000000C8;  // 200  lw $t0, 4($s0)
        ExpPC[24] = 108; ExpData[24] = 32'h00000007;  // 7  addi $t1, $zero, 7
        ExpPC[25] = 112; ExpData[25] = 32'h000000CF;  // 207  add $t2, $t1, $t0
        ExpPC[26] = 120; ExpData[26] = 32'h000000CF;  // 207  lw $t3, 8($s0)
        ExpPC[27] = 128; ExpData[27] = 32'h000000CF;  // 207  lw $t4, 12($s0)
        ExpPC[28] = 136; ExpData[28] = 32'h00000100;  // 256  lw $t5, 16($s0)
        ExpPC[29] = 140; ExpData[29] = 32'h000000C8;  // 200  lw $t6, 4($t5)
        ExpPC[30] = 144; ExpData[30] = 32'hFFFFFFE1;  // -31  addi $t7, $zero, -31
        ExpPC[31] = 152; ExpData[31] = 32'h00007F5A;  // 32602  addi $t8, $zero, 32602
        ExpPC[32] = 160; ExpData[32] = 32'hFFFF8000;  // -32768  addi $t9, $zero, -32768
        ExpPC[33] = 168; ExpData[33] = 32'h80005AE1;  // -2147460383  lw $s1, 20($s0)
        ExpPC[34] = 172; ExpData[34] = 32'hFFFFFFE1;  // -31  lb $s2, 20($s0)
        ExpPC[35] = 176; ExpData[35] = 32'h0000005A;  // 90  lb $s3, 21($s0)
        ExpPC[36] = 180; ExpData[36] = 32'hFFFF8000;  // -32768  lh $s4, 22($s0)
        ExpPC[37] = 184; ExpData[37] = 32'h00005AE1;  // 23265  lh $s5, 20($s0)
        ExpPC[38] = 188; ExpData[38] = 32'hFFFFFF80;  // -128  lb $s6, 23($s0)
        ExpPC[39] = 192; ExpData[39] = 32'h00005A61;  // 23137  add $s7, $s6, $s5
        ExpPC[40] = 200; ExpData[40] = 32'h00005A61;  // 23137  lh $v0, 24($s0)
        ExpPC[41] = 208; ExpData[41] = 32'h00000061;  // 97  lb $v1, 28($s0)
        ExpPC[42] = 212; ExpData[42] = 32'h00000005;  // 5  addi $t0, $zero, 5
        ExpPC[43] = 216; ExpData[43] = 32'h00000005;  // 5  addi $t1, $zero, 5
        ExpPC[44] = 224; ExpData[44] = 32'h00000006;  // 6  addi $t2, $t0, 1
        ExpPC[45] = 232; ExpData[45] = 32'h0000000B;  // 11  add $t3, $t2, $t0
        ExpPC[46] = 240; ExpData[46] = 32'h00000005;  // 5  sub $t4, $t3, $t2
        ExpPC[47] = 252; ExpData[47] = 32'h00000005;  // 5  lw $t5, 32($s0)
        ExpPC[48] = 260; ExpData[48] = 32'hFFFFFFFB;  // -5  addi $t6, $t5, -10
        ExpPC[49] = 272; ExpData[49] = 32'hFFFFFFFE;  // -2  addi $t7, $t6, 3
        ExpPC[50] = 284; ExpData[50] = 32'h00000007;  // 7  addi $t8, $t7, 9
        ExpPC[51] = 296; ExpData[51] = 32'hFFFFFFFE;  // -2  addi $t9, $t8, -9
        ExpPC[52] = 316; ExpData[52] = 32'h00000003;  // 3  addi $a1, $a0, 3
        ExpPC[53] = 324; ExpData[53] = 32'h00000007;  // 7  addi $a2, $a1, 4
        ExpPC[54] = 340; ExpData[54] = 32'h00000004;  // 4  addi $v0, $a1, 1
        ExpPC[55] = 344; ExpData[55] = 32'h00000004;  // 4  addi $v1, $a1, 1
        ExpPC[56] = 352; ExpData[56] = 32'h00000001;  // 1  sub $s1, $v1, $a1
        ExpPC[57] = 360; ExpData[57] = 32'h00000002;  // 2  addi $s2, $s1, 1
        ExpPC[58] = 372; ExpData[58] = 32'h00000003;  // 3  addi $s3, $s2, 1
        ExpPC[59] = 384; ExpData[59] = 32'h00000003;  // 3  lw $s4, 36($s0)
        ExpPC[60] = 388; ExpData[60] = 32'h00000005;  // 5  lw $s5, 32($s0)
        ExpPC[61] = 396; ExpData[61] = 32'h00000005;  // 5  addi $s6, $s4, 2
        ExpPC[62] = 400; ExpData[62] = 32'h00000005;  // 5  lw $s7, 32($s0)
        ExpPC[63] = 408; ExpData[63] = 32'h00000006;  // 6  addi $s5, $s7, 1
        ExpPC[64] = 416; ExpData[64] = 32'h00000003;  // 3  addi $t0, $zero, 3
        ExpPC[65] = 420; ExpData[65] = 32'h00000064;  // 100  addi $t1, $zero, 100
        ExpPC[66] = 424; ExpData[66] = 32'h00000002;  // 2  addi $t0, $t0, -1
        ExpPC[67] = 432; ExpData[67] = 32'h0000006E;  // 110  addi $t1, $t1, 10
        ExpPC[68] = 424; ExpData[68] = 32'h00000001;  // 1  addi $t0, $t0, -1
        ExpPC[69] = 432; ExpData[69] = 32'h00000078;  // 120  addi $t1, $t1, 10
        ExpPC[70] = 432; ExpData[70] = 32'h00000082;  // 130  addi $t1, $t1, 10
        ExpPC[71] = 436; ExpData[71] = 32'h000001BC;  // 444  jal func
        ExpPC[72] = 440; ExpData[72] = 32'h0000004D;  // 77  addi $a0, $zero, 77
        ExpPC[73] = 468; ExpData[73] = 32'h0000004E;  // 78  addi $v0, $a0, 1
        ExpPC[74] = 444; ExpData[74] = 32'h0000009B;  // 155  add $a1, $v0, $a0
        ExpPC[75] = 448; ExpData[75] = 32'h000001D8;  // 472  addi $t2, $zero, 472
        ExpPC[76] = 456; ExpData[76] = 32'h0000009C;  // 156  addi $a2, $a1, 1
        ExpPC[77] = 472; ExpData[77] = 32'h00004F38;  // 20280  mul $a3, $a2, $t1
        ExpPC[78] = 476; ExpData[78] = 32'h000013CE;  // 5070  srl $t3, $a3, 2
        ExpPC[79] = 484; ExpData[79] = 32'h00001332;  // 4914  sub $t4, $t3, $a2
    end

    initial begin
        Cycles = 0;
        Writes = 0;
        Errors = 0;
        LastWriteCycle = 0;
        Extra = 0;

        // hold reset for 3 cycles (longer than the 100 ns global reset of the
        // post-route netlist), release it between clock edges
        Reset = 1'b1;
        #(3 * CLK_PERIOD + CLK_PERIOD / 4);
        Reset = 1'b0;
    end

    // outputs change after the rising edge, so sample on the falling edge
    always @(negedge Clk) begin
        if (!Reset) begin
            Cycles = Cycles + 1;

            if (^{PC, WriteData} === 1'bx) begin
                Errors = Errors + 1;
                $display("FAIL cycle %0d: X on PC=%h WriteData=%h", Cycles, PC, WriteData);
            end
            else if (WriteData != 32'd0) begin
                LastWriteCycle = Cycles;
                if (!CHECK)
                    $display("cycle %4d  PC=%0d  WriteData=%0d (%h)",
                             Cycles, PC, $signed(WriteData), WriteData);
                else if (Writes >= NumExpected) begin
                    Errors = Errors + 1;
                    $display("FAIL cycle %4d  PC=%0d  WriteData=%0d  (extra write, program should be done)",
                             Cycles, PC, $signed(WriteData));
                end
                else if (PC !== ExpPC[Writes] || WriteData !== ExpData[Writes]) begin
                    Errors = Errors + 1;
                    $display("FAIL cycle %4d  PC=%0d  WriteData=%0d  expected PC=%0d  WriteData=%0d",
                             Cycles, PC, $signed(WriteData), ExpPC[Writes], $signed(ExpData[Writes]));
                end
                else
                    $display("PASS cycle %4d  PC=%0d  WriteData=%0d", Cycles, PC, $signed(WriteData));
                Writes = Writes + 1;
            end

            if (CHECK && Writes >= NumExpected)
                Extra = Extra + 1;

            if ((CHECK && Extra >= EXTRA_CYCLES) || Cycles >= MAX_CYCLES) begin
                $display("--------------------------------------------------");
                $display("Register writes: %0d (expected %0d)", Writes, CHECK ? NumExpected : Writes);
                $display("Cycles from reset to the last register write: %0d", LastWriteCycle);
                if (!CHECK)
                    $display("CHECK = 0: trace only, nothing compared");
                else if (Errors == 0 && Writes == NumExpected)
                    $display("ALL CHECKS PASSED");
                else begin
                    if (Writes < NumExpected)
                        $display("FAIL: only %0d of %0d writes seen in %0d cycles", Writes, NumExpected, Cycles);
                    $display("%0d ERROR(S)", Errors + (Writes < NumExpected));
                end
                $finish;
            end
        end
    end

endmodule
