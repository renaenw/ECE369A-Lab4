`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Thomas Shing 100%
//
// Module - Lab5Top.v
// Description - FPGA top module for Lab 5 (Nexys A7). Slows the 100 MHz
//               board clock with ClkDiv, runs the datapath on the slow clock,
//               and shows the PC and the register file write data on the
//               eight 7-segment digits with Two4DigitDisplay:
//                 left 4 digits  (NumberB) = $v0[15:0] = X (row)
//                 right 4 digits (NumberA) = $v1[15:0] = Y (col)
//               Values are shown in hex.
//
// Port names match Two4DigitDisplay.xdc from Lab 1 (Clk, Reset, out7,
// en_out), so that constraint file can be reused as is.
//
// Needs in the project: ClkDiv.v, Two4DigitDisplay.v, SevenSegment.v and the
// Lab 4 datapath.
//
// INPUTS:-
// Clk: 100 MHz board clock (pin E3).
// Reset: center push button (pin N17).
//
// OUTPUTS:-
// out7: 7-segment cathodes a..g.
// en_out: 8 digit anodes (active low).
////////////////////////////////////////////////////////////////////////////////

module Lab5Top(Clk, Reset, out7, en_out);


    parameter DIV_VAL = 10000;   // Lab 7: passed to ClkDiv, overrides its default

    input Clk, Reset;
    output [6:0] out7;
    output [7:0] en_out;

    wire SlowClk;
    (* DONT_TOUCH = "TRUE" *) wire [31:0] PC, WriteData;
    (* DONT_TOUCH = "TRUE" *) wire [31:0] V0, V1;   // $v0 = X (row), $v1 = Y (col)


    reg [3:0] PowerOnCount = 4'd0;
    wire PowerOnReset = ~&PowerOnCount;

    always @(posedge Clk) begin
        if (PowerOnReset)
            PowerOnCount <= PowerOnCount + 4'd1;
    end

    ClkDiv #(.DivVal(DIV_VAL)) clkdiv(
        .Clk(Clk),
        .Rst(PowerOnReset),
        .ClkOut(SlowClk)
    );

    reg DatapathReset = 1'b1;
    reg SlowClkPrev = 1'b0;
    reg SawRise = 1'b0;

    always @(posedge Clk) begin
        SlowClkPrev <= SlowClk;
        if (Reset) begin
            DatapathReset <= 1'b1;
            SawRise <= 1'b0;
        end
        else if (DatapathReset) begin
            if (SlowClk & ~SlowClkPrev)
                SawRise <= 1'b1;
            else if (~SlowClk & SlowClkPrev & SawRise)
                DatapathReset <= 1'b0;
        end
    end

    // DONT_TOUCH keeps the Datapath hierarchy and all 32 bits of its PC and
    // WriteData ports in the routed netlist (the display only uses [15:0]).
    (* DONT_TOUCH = "TRUE" *)
    Datapath datapath(
        .Clk(SlowClk),
        .Reset(DatapathReset),
        .PC(PC),
        .WriteData(WriteData),
        .V0(V0),
        .V1(V1)
    );

    // Lab 7: left 4 digits = X ($v0), right 4 digits = Y ($v1)
    Two4DigitDisplay display(
        .Clk(Clk),
        .NumberA(V1[15:0]),
        .NumberB(V0[15:0]),
        .out7(out7),
        .en_out(en_out)
    );

endmodule
