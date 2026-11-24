`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 33.3%
// Thomas Shing 33.3%
// Renae Weiss 33.3%
//
// Module - Lab7_tb.v
// Description - Display testbench for Lab 7. Runs Lab5Top with the
//               Tests/lab7_display_test program (load its .mem as
//               instruction_memory.mem) and reads (X, Y) back off the
//               7-segment display:
//                 left 4 digits  (en_out[7:4]) = $v0 = X
//                 right 4 digits (en_out[3:0]) = $v1 = Y
//
//   Uses ONLY the top-level ports (Clk, Reset, out7, en_out) and no
//   parameter override, so it runs unchanged as a behavioral simulation
//   AND as a post-implementation (functional or timing) simulation.
//
//   1) Every time the decoded display changes, prints "X Y" in hex.
//   2) Checks the sequence 0000 0000 -> 0000 0001 -> 0001 0001 -> 0001 0002.
//   3) Presses Reset after the program finishes and checks that every digit
//      goes back to 0 ($v0/$v1 cleared on reset, display at (0,0)).
//
//   Timing (DivVal = 10000, one datapath cycle = 200 us): the program holds
//   each (X, Y) for ~13 ms, one display scan takes 10.5 ms, the final value
//   is written at ~46 ms.
////////////////////////////////////////////////////////////////////////////////

module Lab7_tb();

    parameter RESET_AT = 60000000;   // ns, Reset press (program done by ~46 ms)
    parameter SIM_TIME = 75000000;   // ns, end of simulation
    parameter SETTLE   = 100;        // board clocks a digit must be steady before it is read

    reg Clk, Reset;
    wire [6:0] out7;
    wire [7:0] en_out;

    Lab5Top uut(
        .Clk(Clk),
        .Reset(Reset),
        .out7(out7),
        .en_out(en_out)
    );

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

    // expected (X, Y) sequence = {X[15:0], Y[15:0]}
    reg [31:0] Expected [0:3];
    initial begin
        Expected[0] = {16'h0000, 16'h0000};
        Expected[1] = {16'h0000, 16'h0001};
        Expected[2] = {16'h0001, 16'h0001};
        Expected[3] = {16'h0001, 16'h0002};
    end

    reg  [3:0] Shown [0:7];     // last value read from each digit
    reg  [7:0] Seen;            // digit has been read at least once
    reg  [7:0] AfterReset;      // digit has been read since the Reset press
    reg  [7:0] LastEn;
    reg  [6:0] LastSeg;
    reg  [31:0] Display, LastDisplay;
    reg  [4:0] Value;
    reg  Pressed;
    integer Steady, Digit, i, Errors, Changes, Next;

    // the one lit digit (en_out is active low), -1 if not exactly one
    function integer LitDigit;
        input [7:0] en;
        integer k;
        begin
            LitDigit = -1;
            for (k = 0; k < 8; k = k + 1)
                if (en == ~(8'b1 << k))
                    LitDigit = k;
        end
    endfunction

    initial begin
        Errors = 0; Changes = 0; Next = 0; Steady = 0;
        Seen = 8'd0; AfterReset = 8'd0; Pressed = 1'b0;
        LastEn = 8'hFF; LastSeg = 7'h7F; LastDisplay = 32'hFFFFFFFF;
        Reset = 1'b0;

        // Reset button pressed for 20 ns after the program has finished
        #(RESET_AT);
        $display("[%0d.%01d ms] ---- Reset button pressed ----", $time / 1000000, ($time / 100000) % 10);
        Reset = 1'b1;
        #20 Reset = 1'b0;
        // give the datapath one slow clock (~0.2 ms) to clear $v0/$v1
        #(1000000);
        Pressed = 1'b1;
    end

    // read a digit once it has been lit with the same segments for SETTLE clocks
    always @(posedge Clk) begin
        if (en_out === LastEn && out7 === LastSeg)
            Steady = Steady + 1;
        else
            Steady = 0;
        LastEn = en_out;
        LastSeg = out7;

        Digit = LitDigit(en_out);
        if (Steady == SETTLE && Digit >= 0) begin
            Value = Decode(out7);
            if (Value[4]) begin
                Errors = Errors + 1;
                $display("[%0d.%01d ms] FAIL: digit %0d shows an invalid pattern out7=%b",
                         $time / 1000000, ($time / 100000) % 10, Digit, out7);
            end
            else begin
                Shown[Digit] = Value[3:0];
                Seen[Digit] = 1'b1;

                // 3) after Reset: the first read of every digit must be 0
                if (Pressed && !AfterReset[Digit]) begin
                    AfterReset[Digit] = 1'b1;
                    if (Value[3:0] !== 4'h0) begin
                        Errors = Errors + 1;
                        $display("[%0d.%01d ms] FAIL reset: digit %0d shows %h, expected 0",
                                 $time / 1000000, ($time / 100000) % 10, Digit, Value[3:0]);
                    end
                end
            end

            // 1) + 2) report and check each new value once all 8 digits are known
            if (Seen == 8'hFF) begin
                Display = {Shown[7], Shown[6], Shown[5], Shown[4],
                           Shown[3], Shown[2], Shown[1], Shown[0]};
                if (Display !== LastDisplay) begin
                    $display("[%0d.%01d ms] display  X = %h   Y = %h",
                             $time / 1000000, ($time / 100000) % 10, Display[31:16], Display[15:0]);
                    LastDisplay = Display;
                    if (!Pressed && $time < RESET_AT) begin
                        Changes = Changes + 1;
                        if (Next < 4 && Display === Expected[Next])
                            Next = Next + 1;
                        else begin
                            Errors = Errors + 1;
                            $display("            FAIL: expected X = %h   Y = %h",
                                     Expected[(Next < 4) ? Next : 3][31:16],
                                     Expected[(Next < 4) ? Next : 3][15:0]);
                        end
                    end
                end
            end
        end
    end

    // summary
    initial begin
        #(SIM_TIME);
        $display("--------------------------------------------------");
        if (Next != 4) begin
            Errors = Errors + 1;
            $display("FAIL: saw %0d of the 4 expected (X, Y) values", Next);
        end
        if (AfterReset != 8'hFF) begin
            Errors = Errors + 1;
            $display("FAIL reset: digits read after Reset = %b (need all 8)", AfterReset);
        end
        if (Errors == 0)
            $display("ALL CHECKS PASSED: display showed (0,0) (0,1) (1,1) (1,2), then (0,0) after Reset");
        else
            $display("%0d ERROR(S)", Errors);
        $finish;
    end

endmodule
