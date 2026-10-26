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
//                 left 4 digits  (NumberB) = PC[15:0]
//                 right 4 digits (NumberA) = WriteData[15:0]
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

    // 1 Hz datapath clock: DIV_VAL = 100MHz / (2 * desired Hz).
    // The testbench lowers this so simulation finishes quickly.
    parameter DIV_VAL = 50000000;

    input Clk, Reset;
    output [6:0] out7;
    output [7:0] en_out;

    wire SlowClk;
    wire [31:0] PC, WriteData;

    // ClkDiv has no initial values, so give it a short reset at power up only.
    // After that it keeps running, so the datapath still gets clock edges
    // while the Reset button is held.
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

    // A button press is much shorter than one slow clock period, so hold the
    // datapath reset until the slow clock has had a rising edge and then a
    // falling edge after the button is released. Also held at power up.
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

    // Lab 4 top module (Pipeline/Datapath.v)
    Datapath datapath(
        .Clk(SlowClk),
        .Reset(DatapathReset),
        .PC(PC),
        .WriteData(WriteData)
    );

    Two4DigitDisplay display(
        .Clk(Clk),
        .NumberA(WriteData[15:0]),
        .NumberB(PC[15:0]),
        .out7(out7),
        .en_out(en_out)
    );

endmodule
