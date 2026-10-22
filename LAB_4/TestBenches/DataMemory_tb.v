`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Original testbench: Thomas Shing
// Updated for Lab 4 - Added automatic PASS/FAIL verification by Renae Weiss
// Module - DataMemory_tb.v
//
// Additional Lab 4 Updates - Renae Weiss
// - Added MemSize input for word, halfword, and byte operations.
// - Added tests for lb, lh, sb, and sh.
// - Added sign extension and partial-write verification.
// - Preserved the original 10 full-word tests.
////////////////////////////////////////////////////////////////////////////////

module DataMemory_tb();

    reg [31:0] Address;
    reg [31:0] WriteData;
    reg Clk;
    reg MemWrite;
    reg MemRead;
    reg [1:0] MemSize;

    wire [31:0] ReadData;

    integer passed = 0;
    integer failed = 0;

    DataMemory u0(
        .Address(Address),
        .WriteData(WriteData),
        .Clk(Clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .MemSize(MemSize),
        .ReadData(ReadData)
    );

    // Clock generator
    initial begin
        Clk = 0;
        forever #10 Clk = ~Clk;
    end

    // Check actual value against expected value
    task checkResult;
        input [31:0] expected;
        begin
            if (ReadData === expected) begin
                $display("PASS: Expected %h, Got %h",
                         expected, ReadData);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: Expected %h, Got %h",
                         expected, ReadData);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        MemWrite = 0;
        MemRead = 0;
        MemSize = 2'b00;
        Address = 0;
        WriteData = 0;
        
        // Lab 4: Verify data loaded from data_memory.mem
        #1;
        MemRead = 1;
        Address = 32'h00000000;
        #1;
        $display("Test: Memory initialization using $readmemh");
        checkResult(32'h12345678);

        MemRead = 0;

        // Test 1: Basic write then read back
        @(negedge Clk);
        Address = 32'h00000004;
        WriteData = 32'hDEADBEEF;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0;
        MemRead = 1;
        #1;
        $display("Test 1: Basic write/read");
        checkResult(32'hDEADBEEF);

        // Test 2: MemRead=0 forces ReadData to 0
        MemRead = 0;
        #1;
        $display("Test 2: Read disabled");
        checkResult(32'h00000000);

        // Test 3: Write and read address 0
        @(negedge Clk);
        MemRead = 0;
        Address = 32'h00000000;
        WriteData = 32'hCAFEBABE;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0;
        MemRead = 1;
        #1;
        $display("Test 3: Address 0");
        checkResult(32'hCAFEBABE);

        // Test 4: Last valid memory address
        @(negedge Clk);
        MemRead = 0;
        Address = 32'h00000FFC;
        WriteData = 32'h12345678;
        MemWrite = 1;
        @(posedge Clk); #1;
        MemWrite = 0;
        MemRead = 1;
        #1;
        $display("Test 4: Last address");
        checkResult(32'h12345678);

        // Test 5: Independent memory locations
        @(negedge Clk);
        MemRead = 0;
        Address = 32'h00000008;
        WriteData = 32'hAAAAAAAA;
        MemWrite = 1;
        @(posedge Clk); #1;

        @(negedge Clk);
        Address = 32'h0000000C;
        WriteData = 32'hBBBBBBBB;
        @(posedge Clk); #1;

        MemWrite = 0;
        MemRead = 1;

        Address = 32'h00000008;
        #1;
        $display("Test 5A: Address 8");
        checkResult(32'hAAAAAAAA);

        Address = 32'h0000000C;
        #1;
        $display("Test 5B: Address 12");
        checkResult(32'hBBBBBBBB);

        // Test 6: MemWrite=0 prevents overwrite
        @(negedge Clk);
        MemRead = 0;
        Address = 32'h00000004;
        WriteData = 32'h00000000;
        MemWrite = 0;
        @(posedge Clk); #1;
        MemRead = 1;
        #1;
        $display("Test 6: Write disabled");
        checkResult(32'hDEADBEEF);

        // Test 7: Address bits [1:0] ignored for word reads
        @(negedge Clk);
        MemRead = 0;
        Address = 32'h00000010;
        WriteData = 32'hFEEDFACE;
        MemWrite = 1;
        @(posedge Clk); #1;

        MemWrite = 0;
        MemRead = 1;

        Address = 32'h00000010;
        #1;
        $display("Test 7A: Address 0x10");
        checkResult(32'hFEEDFACE);

        Address = 32'h00000013;
        #1;
        $display("Test 7B: Address 0x13");
        checkResult(32'hFEEDFACE);

        // Test 8: Overwrite an existing location
        @(negedge Clk);
        MemRead = 0;
        Address = 32'h00000004;
        WriteData = 32'hC0FFEE00;
        MemWrite = 1;
        @(posedge Clk); #1;

        MemWrite = 0;
        MemRead = 1;
        #1;
        $display("Test 8: Overwrite");
        checkResult(32'hC0FFEE00);

        ////////////////////////////////////////////////////////////////
        // NEW LAB 4 TESTS
        ////////////////////////////////////////////////////////////////

        // Test 9: lb - load negative byte with sign extension
        MemSize = 2'b10;
        Address = 32'h00000000;
        #1;
        $display("Test 9: lb negative byte");
        checkResult(32'hFFFFFFBE);
        
        // Test 10: lb - load negative byte with sign extension
        Address = 32'h00000001;
        #1;
        $display("Test 10: lb negative byte");
        checkResult(32'hFFFFFFBA);

        // Test 11: lh - load negative lower halfword
        MemSize = 2'b01;
        Address = 32'h00000000;
        #1;
        $display("Test 11: lh lower halfword");
        checkResult(32'hFFFFBABE);

        // Test 12: lh - load negative upper halfword
        Address = 32'h00000002;
        #1;
        $display("Test 12: lh upper halfword");
        checkResult(32'hFFFFCAFE);

        // Test 13: sb - overwrite one byte
        @(negedge Clk);
        MemRead = 0;
        MemSize = 2'b10;
        Address = 32'h00000001;
        WriteData = 32'h00000055;
        MemWrite = 1;
        @(posedge Clk); #1;

        MemWrite = 0;
        MemRead = 1;
        MemSize = 2'b00;
        Address = 32'h00000000;
        #1;
        $display("Test 13: sb preserves other bytes");
        checkResult(32'hCAFE55BE);

        // Test 14: sh - overwrite upper halfword
        @(negedge Clk);
        MemRead = 0;
        MemSize = 2'b01;
        Address = 32'h00000002;
        WriteData = 32'h00001234;
        MemWrite = 1;
        @(posedge Clk); #1;

        MemWrite = 0;
        MemRead = 1;
        MemSize = 2'b00;
        Address = 32'h00000000;
        #1;
        $display("Test 14: sh preserves lower halfword");
        checkResult(32'h123455BE);

        // Test 15: lb - verify byte after store
        MemSize = 2'b10;
        Address = 32'h00000001;
        #1;
        $display("Test 15: lb after sb");
        checkResult(32'h00000055);

        // Test 16: lh - verify halfword after store
        MemSize = 2'b01;
        Address = 32'h00000002;
        #1;
        $display("Test 16: lh after sh");
        checkResult(32'h00001234);

        // Test 17: Read disabled for byte operations
        MemSize = 2'b10;
        MemRead = 0;
        #1;
        $display("Test 17: Byte read disabled");
        checkResult(32'h00000000);
        
        // Test 18: lb - load positive byte
        MemRead = 1;
        MemSize = 2'b10;
        Address = 32'h00000001;
        #1;
        $display("Test 18: lb positive byte");
        checkResult(32'h00000055);

        // Final summary
        $display("---------------------------");
        $display("Tests Passed: %0d", passed);
        $display("Tests Failed: %0d", failed);
        $display("---------------------------");

        $finish;
    end

endmodule

