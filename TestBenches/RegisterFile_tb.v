`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - RegisterFile.v
// Description - Test the register_file
// Suggested test case - First write arbitrary values into 
// the saved and temporary registers (i.e., register 8 through 25). Then, 2-by-2, 
// read values from these registers.
////////////////////////////////////////////////////////////////////////////////


module RegisterFile_tb();

    reg [4:0] ReadRegister1;
    reg [4:0] ReadRegister2;
    reg [4:0] WriteRegister;
    reg [31:0] WriteData;
    reg RegWrite;
    reg Clk;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;


    RegisterFile u0(
        .ReadRegister1(ReadRegister1), 
        .ReadRegister2(ReadRegister2), 
        .WriteRegister(WriteRegister), 
        .WriteData(WriteData), 
        .RegWrite(RegWrite), 
        .Clk(Clk), 
        .ReadData1(ReadData1), 
        .ReadData2(ReadData2)
    );


    // Generate clock
    initial begin
        Clk <= 1'b0;
        forever #10 Clk <= ~Clk;
    end


    initial begin

        // Initialize signals
        ReadRegister1 <= 5'd0;
        ReadRegister2 <= 5'd0;
        WriteRegister <= 5'd0;
        WriteData <= 32'd0;
        RegWrite <= 1'b0;


        // Prepare the first write while RegWrite is disabled
        #40;
        WriteRegister <= 5'd8;
        WriteData <= 32'h00000008;

        // Allow address and data to settle
        #20;

        // Enable register writing
        RegWrite <= 1'b1;

        // Allow a rising clock edge to write register 8
        #40;


        // Continue writing registers 9 through 25

        WriteRegister <= 5'd9;
        WriteData <= 32'h00000009;
        #40;

        WriteRegister <= 5'd10;
        WriteData <= 32'h0000000A;
        #40;

        WriteRegister <= 5'd11;
        WriteData <= 32'h0000000B;
        #40;

        WriteRegister <= 5'd12;
        WriteData <= 32'h0000000C;
        #40;

        WriteRegister <= 5'd13;
        WriteData <= 32'h0000000D;
        #40;

        WriteRegister <= 5'd14;
        WriteData <= 32'h0000000E;
        #40;

        WriteRegister <= 5'd15;
        WriteData <= 32'h0000000F;
        #40;

        WriteRegister <= 5'd16;
        WriteData <= 32'h00000010;
        #40;

        WriteRegister <= 5'd17;
        WriteData <= 32'h00000011;
        #40;

        WriteRegister <= 5'd18;
        WriteData <= 32'h00000012;
        #40;

        WriteRegister <= 5'd19;
        WriteData <= 32'h00000013;
        #40;

        WriteRegister <= 5'd20;
        WriteData <= 32'h00000014;
        #40;

        WriteRegister <= 5'd21;
        WriteData <= 32'h00000015;
        #40;

        WriteRegister <= 5'd22;
        WriteData <= 32'h00000016;
        #40;

        WriteRegister <= 5'd23;
        WriteData <= 32'h00000017;
        #40;

        WriteRegister <= 5'd24;
        WriteData <= 32'h00000018;
        #40;

        WriteRegister <= 5'd25;
        WriteData <= 32'h00000019;
        #40;


        // Stop writing
        RegWrite <= 1'b0;

        // Allow final write to settle
        #20;


        // Read registers back two at a time

        ReadRegister1 <= 5'd8;
        ReadRegister2 <= 5'd9;
        #40;
        $display("R8=%h, R9=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd10;
        ReadRegister2 <= 5'd11;
        #40;
        $display("R10=%h, R11=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd12;
        ReadRegister2 <= 5'd13;
        #40;
        $display("R12=%h, R13=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd14;
        ReadRegister2 <= 5'd15;
        #40;
        $display("R14=%h, R15=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd16;
        ReadRegister2 <= 5'd17;
        #40;
        $display("R16=%h, R17=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd18;
        ReadRegister2 <= 5'd19;
        #40;
        $display("R18=%h, R19=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd20;
        ReadRegister2 <= 5'd21;
        #40;
        $display("R20=%h, R21=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd22;
        ReadRegister2 <= 5'd23;
        #40;
        $display("R22=%h, R23=%h", ReadData1, ReadData2);

        ReadRegister1 <= 5'd24;
        ReadRegister2 <= 5'd25;
        #40;
        $display("R24=%h, R25=%h", ReadData1, ReadData2);

    end

endmodule
