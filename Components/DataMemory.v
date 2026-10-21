
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Thomas Shing 100%
// 
// Module - data_memory.v
// Description - 32-Bit wide data memory.
//
// INPUTS:-
// Address: 32-Bit address input port.
// WriteData: 32-Bit input port.
// Clk: 1-Bit Input clock signal.
// MemWrite: 1-Bit control signal for memory write.
// MemRead: 1-Bit control signal for memory read.
//
// OUTPUTS:-
// ReadData: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design the above memory similar to the 'RegisterFile' model in the previous 
// assignment.  Create a 1K memory, for which we need 10 bits.  In order to 
// implement byte addressing, we will use bits Address[11:2] to index the 
// memory location. The 'WriteData' value is written into the address 
// corresponding to Address[11:2] in the positive clock edge if 'MemWrite' 
// signal is 1. 'ReadData' is the value of memory location Address[11:2] if 
// 'MemRead' is 1, otherwise, it is 0x00000000. The reading of memory is not 
// clocked.
//
// you need to declare a 2d array. in this case we need an array of 1024 (1K)  
// 32-bit elements for the memory.   
// for example,  to declare an array of 256 32-bit elements, declaration is: reg[31:0] memory[0:255]
// if i continue with the same declaration, we need 8 bits to index to one of 256 elements. 
// however , address port for the data memory is 32 bits. from those 32 bits, least significant 2 
// bits help us index to one of the 4 bytes within a single word. therefore we only need bits [9-2] 
// of the "Address" input to index any of the 256 words.
//
// Lab 4 Updates - Renae Weiss
// - Added MemSize input to support word, halfword, and byte operations.
// - Added support for lb, lh, sb, and sh instructions.
// - Added sign extension for byte and halfword loads.
// - Updated store operations to preserve unaffected bytes in memory.
// - Maintained existing lw and sw functionality from Lab 3.
////////////////////////////////////////////////////////////////////////////////


module DataMemory(
    Address, WriteData, Clk, MemWrite, MemRead, MemSize, ReadData
);

    input [31:0] Address;
    input [31:0] WriteData;
    input Clk;
    input MemWrite;
    input MemRead;
    input [1:0] MemSize;

    output reg [31:0] ReadData;

    // 1024 words, each 32 bits
    reg [31:0] memory [0:1023];

    // Address[11:2] selects the word.
    // Address[1:0] selects the byte within that word.
    wire [9:0] WordAddress = Address[11:2];
    wire [1:0] ByteOffset = Address[1:0];

    reg [31:0] SelectedWord;
    reg [7:0] SelectedByte;
    reg [15:0] SelectedHalf;

    integer i;

    // Initialize memory to zero, then load data from the .mem file
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'b0;
    
        $readmemh("data_memory.mem", memory);
    end

    // WRITE OPERATIONS
    always @(posedge Clk) begin
        if (MemWrite) begin
            case (MemSize)

                // sw - store full word
                2'b00: begin
                    memory[WordAddress] <= WriteData;
                end

                // sh - store lower 16 bits into selected halfword
                2'b01: begin
                    if (ByteOffset[1] == 1'b0)
                        memory[WordAddress][15:0] <= WriteData[15:0];
                    else
                        memory[WordAddress][31:16] <= WriteData[15:0];
                end

                // sb - store lower 8 bits into selected byte
                2'b10: begin
                    case (ByteOffset)
                        2'b00: memory[WordAddress][7:0]   <= WriteData[7:0];
                        2'b01: memory[WordAddress][15:8]  <= WriteData[7:0];
                        2'b10: memory[WordAddress][23:16] <= WriteData[7:0];
                        2'b11: memory[WordAddress][31:24] <= WriteData[7:0];
                    endcase
                end

                default: ;
            endcase
        end
    end

    // READ OPERATIONS
    always @(*) begin
        SelectedWord = memory[WordAddress];

        // Select byte based on lowest two address bits
        case (ByteOffset)
            2'b00: SelectedByte = SelectedWord[7:0];
            2'b01: SelectedByte = SelectedWord[15:8];
            2'b10: SelectedByte = SelectedWord[23:16];
            2'b11: SelectedByte = SelectedWord[31:24];
        endcase

        // Select lower or upper halfword
        if (ByteOffset[1] == 1'b0)
            SelectedHalf = SelectedWord[15:0];
        else
            SelectedHalf = SelectedWord[31:16];

        ReadData = 32'b0;

        if (MemRead) begin
            case (MemSize)

                // lw - load full word
                2'b00: ReadData = SelectedWord;

                // lh - load signed halfword
                2'b01: ReadData = {{16{SelectedHalf[15]}}, SelectedHalf};

                // lb - load signed byte
                2'b10: ReadData = {{24{SelectedByte[7]}}, SelectedByte};

                default: ReadData = 32'b0;
            endcase
        end
    end

endmodule