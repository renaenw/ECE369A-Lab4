`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Thomas Shing 100%
//
// Module - Lab5Top_tb.v
// Description - Testbench for Lab5Top.v (datapath + ClkDiv + Two4DigitDisplay)
//               driven the way the Nexys A7 drives it: a 100 MHz clock and the
//               Reset push button.
//
//   1) Display check: whenever one digit is lit (en_out, active low), its
//      segments (out7) are decoded back to a hex digit and compared with the
//      matching 4 bits of the value it should show:
//        en_out[3:0] -> WriteData[15:0]   (right 4 digits)
//        en_out[7:4] -> PC[15:0]          (left 4 digits)
//      Every digit must be checked at least once with no mismatches.
//   2) Trace: prints the PC and the register file write data (decimal and
//      hex, as the board shows it) every datapath cycle that writes a register.
//   3) Reset button: a 20 ns press partway through must restart the datapath
//      (PC and WriteData back to 0, then the program runs again).
//
//   DIV_VAL lowers the clock divider so the datapath runs at about 25 kHz in
//   simulation instead of 1 Hz. The display refresh is unchanged, so one full
//   scan of the 8 digits takes about 10.5 ms of simulated time.
//
//   Uses internal signals of Lab5Top (PC, WriteData, SlowClk, DatapathReset),
//   so run it as a behavioral simulation.
//
// Files needed: Lab5Top.v, ClkDiv.v, Two4DigitDisplay.v, SevenSegment.v,
// the datapath sources, instruction_memory.mem and data_memory.mem.
////////////////////////////////////////////////////////////////////////////////

module Lab5Top_tb();

    parameter DIV_VAL   = 2000;       // datapath clock period = 2*(DIV_VAL+1)*10 ns (~40 us)
    parameter RESET_AT  = 15000000;   // ns, time of the Reset button press
    parameter SIM_TIME  = 30000000;   // ns, total simulated time

    reg Clk, Reset;
    wire [6:0] out7;
    wire [7:0] en_out;

    Lab5Top #(.DIV_VAL(DIV_VAL)) uut(
        .Clk(Clk),
        .Reset(Reset),
        .out7(out7),
        .en_out(en_out)
    );

    integer Errors, ResetErrors, Writes, i;
    integer DigitChecks [0:7];
    integer Stable;
    reg [31:0] LastPC, LastWriteData;
    reg [2:0] Digit;
    reg [3:0] Shown, Want;
    reg OneDigitLit;

    // 100 MHz board clock
    initial Clk = 1'b0;
    always #5 Clk = ~Clk;

    // segment pattern -> hex digit (same table as SevenSegment.v);
    // 5'h10 means the pattern is not a valid digit
    function [4:0] Decode;
        input [6:0] seg;
        begin
            case (seg)
                7'b0000001: Decode = 5'h0;
                7'b1001111: Decode = 5'h1;
                7'b0010010: Decode = 5'h2;
                7'b0000110: Decode = 5'h3;
                7'b1001100: Decode = 5'h4;
                7'b0100100: Decode = 5'h5;
                7'b0100000: Decode = 5'h6;
                7'b0001111: Decode = 5'h7;
                7'b0000000: Decode = 5'h8;
                7'b0000100: Decode = 5'h9;
                7'b0001000: Decode = 5'hA;
                7'b1100000: Decode = 5'hB;
                7'b0110001: Decode = 5'hC;
                7'b1000010: Decode = 5'hD;
                7'b0110000: Decode = 5'hE;
                7'b0111000: Decode = 5'hF;
                default:    Decode = 5'h10;
            endcase
        end
    endfunction

    initial begin
        Errors = 0;
        ResetErrors = 0;
        Writes = 0;
        Stable = 0;
        LastPC = 32'd0;
        LastWriteData = 32'd0;
        for (i = 0; i < 8; i = i + 1)
            DigitChecks[i] = 0;

        // no button press at power up; Lab5Top holds the datapath in reset
        Reset = 1'b0;

        // press the Reset button for 20 ns, far shorter than one datapath cycle
        #(RESET_AT);
        $display("---- Reset button pressed at %0d ms ----", $time / 1000000);
        Reset = 1'b1;
        #20 Reset = 1'b0;

        // the datapath must come out of reset with PC and WriteData at 0
        @(negedge uut.DatapathReset);
        if (uut.PC !== 32'd0 || uut.WriteData !== 32'd0) begin
            $display("FAIL reset: PC=%h WriteData=%h after the button press", uut.PC, uut.WriteData);
            ResetErrors = ResetErrors + 1;
        end
        else
            $display("PASS reset: datapath restarted from PC=0");
    end

    // 2) trace of register writes, one line per datapath cycle
    always @(negedge uut.SlowClk) begin
        if (!uut.DatapathReset && uut.WriteData != 32'd0) begin
            Writes = Writes + 1;
            $display("PC=%0d  WriteData=%0d   display: %h %h", uut.PC, $signed(uut.WriteData),
                     uut.PC[15:0], uut.WriteData[15:0]);
        end
    end

    // 1) display check on every board clock
    always @(negedge Clk) begin
        // the display updates one board clock after the values change,
        // so only check values that have been stable for 2 clocks
        if (uut.PC === LastPC && uut.WriteData === LastWriteData)
            Stable = Stable + 1;
        else
            Stable = 0;
        LastPC = uut.PC;
        LastWriteData = uut.WriteData;

        OneDigitLit = 1'b0;
        Digit = 3'd0;
        for (i = 0; i < 8; i = i + 1)
            if (en_out == ~(8'b1 << i)) begin
                OneDigitLit = 1'b1;
                Digit = i;
            end

        if (Stable >= 2 && OneDigitLit && ^{uut.PC, uut.WriteData} !== 1'bx) begin
            if (Digit < 4)
                Want = uut.WriteData[Digit * 4 +: 4];
            else
                Want = uut.PC[(Digit - 4) * 4 +: 4];
            Shown = Decode(out7);

            DigitChecks[Digit] = DigitChecks[Digit] + 1;
            if (Decode(out7) !== {1'b0, Want}) begin
                Errors = Errors + 1;
                if (Errors <= 10)
                    $display("FAIL display: digit %0d shows %h (out7=%b), expected %h  [PC=%h WriteData=%h]",
                             Digit, Shown, out7, Want, uut.PC[15:0], uut.WriteData[15:0]);
            end
        end
    end

    // summary
    initial begin
        #(SIM_TIME);
        $display("--------------------------------------------------");
        $display("Register writes traced: %0d", Writes);
        for (i = 0; i < 8; i = i + 1)
            if (DigitChecks[i] == 0) begin
                $display("FAIL display: digit %0d was never checked", i);
                Errors = Errors + 1;
            end
        $display("Display checks per digit (0-3 WriteData, 4-7 PC): %0d %0d %0d %0d | %0d %0d %0d %0d",
                 DigitChecks[0], DigitChecks[1], DigitChecks[2], DigitChecks[3],
                 DigitChecks[4], DigitChecks[5], DigitChecks[6], DigitChecks[7]);
        if (Errors == 0 && ResetErrors == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("%0d DISPLAY ERROR(S), %0d RESET ERROR(S)", Errors, ResetErrors);
        $finish;
    end

endmodule
