`timescale 1ns / 1ps
 
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Karyna Kuzhelnykova 33.3%
// Thomas Shing 33.3%
// Renae Weiss 33.3%
// Module - Datapath.v
// Description - Top module of the 5-stage pipelined MIPS datapath.
//               PC is the PC of the instruction in WB, WriteData is the value
//               it writes to the register file (0 if nothing is written).
////////////////////////////////////////////////////////////////////////////////
 
module Datapath(input Clk, Reset, output [31:0] PC, WriteData);
 
    // wires are named <stage>_<port name>
    wire [31:0] IF_PCResult, IF_PCAddResult, IF_Instruction, IF_PCNext;
    
    wire [31:0] ID_PCResult, ID_PCAddResult, ID_Instruction, ID_ReadData1, ID_ReadData2, ID_Immediate, ID_JumpTarget;
    wire ID_RegWrite, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_Branch, ID_ALUSrc, ID_ShiftSrc, ID_ZeroExt, ID_Link;
    wire ID_Jump, ID_JumpReg;
    wire [1:0] ID_MemSize, ID_RegDst;
    wire [2:0] ID_BranchType;
    wire [3:0] ID_ALUControl;
 
    wire [31:0] EX_PCResult, EX_PCPlus4, EX_ReadData1, EX_ReadData2, EX_Immediate;
    wire [31:0] EX_ALUResult, EX_BranchTarget, EX_MemWriteData;
    wire EX_RegWrite, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_Branch, EX_ALUSrc, EX_ShiftSrc, EX_ZeroExt, EX_Link;
    wire EX_BranchCond;
    wire [1:0] EX_MemSize, EX_RegDst;
    wire [2:0] EX_BranchType;
    wire [3:0] EX_ALUControl;
    wire [4:0] EX_Rt, EX_Rd, EX_WriteRegister;
 
    wire [31:0] MEM_PCResult, MEM_ALUResult, MEM_BranchTarget, MEM_MemWriteData, MEM_ReadData;
    wire MEM_RegWrite, MEM_MemtoReg, MEM_MemRead, MEM_MemWrite, MEM_Branch, MEM_BranchCond;
    wire [1:0] MEM_MemSize;
    wire [4:0] MEM_WriteRegister;

    wire [31:0] WB_PCResult, WB_ALUResult, WB_ReadData, WB_WriteData;
    wire WB_RegWrite, WB_MemtoReg;
    wire [4:0] WB_WriteRegister;
 
    // IF - Karyna
    // branches decided in MEM, jump in ID
    assign IF_PCNext = (MEM_Branch & MEM_BranchCond) ? MEM_BranchTarget : 
                       (ID_Jump | ID_JumpReg)        ? ID_JumpTarget    :
                                                       IF_PCAddResult;
    
    ProgramCounter pcreg(.Clk(Clk), .Reset(Reset), .PCNext(IF_PCNext), .PCResult(IF_PCResult));
    PCAdder pcadder(.PCResult(IF_PCResult), .PCAddResult(IF_PCAddResult));
    InstructionMemory imem(.Address(IF_PCResult), .Instruction(IF_Instruction));
 
    IF_ID ifid(.Clk(Clk), .Reset(Reset),
        .PCResultIn(IF_PCResult), .PCAddResultIn(IF_PCAddResult), .InstructionIn(IF_Instruction),
        .PCResultOut(ID_PCResult), .PCAddResultOut(ID_PCAddResult), .InstructionOut(ID_Instruction));
 
    // ID - Karyna
    Controller ctrl(.Instruction(ID_Instruction),
        .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg), .MemRead(ID_MemRead), .MemWrite(ID_MemWrite),
        .MemSize(ID_MemSize), .Branch(ID_Branch), .BranchType(ID_BranchType), .Jump(ID_Jump), .JumpReg(ID_JumpReg),
        .RegDst(ID_RegDst), .ALUSrc(ID_ALUSrc), .ShiftSrc(ID_ShiftSrc), .ZeroExt(ID_ZeroExt),
        .Link(ID_Link), .ALUControl(ID_ALUControl));
 
    RegisterFile rf(.ReadRegister1(ID_Instruction[25:21]), .ReadRegister2(ID_Instruction[20:16]),
        .WriteRegister(WB_WriteRegister), .WriteData(WB_WriteData), .RegWrite(WB_RegWrite),
        .Clk(Clk), .ReadData1(ID_ReadData1), .ReadData2(ID_ReadData2));
 
    SignExtension signext(.in(ID_Instruction[15:0]), .out(ID_Immediate));
    
    // jr: $rs
    assign ID_JumpTarget = ID_JumpReg ? ID_ReadData1 : {ID_PCAddResult[31:28], ID_Instruction[25:0], 2'b00};
    
    ID_EX idex(.Clk(Clk), .Reset(Reset),
        .RegWriteIn(ID_RegWrite), .MemtoRegIn(ID_MemtoReg), .MemReadIn(ID_MemRead), .MemWriteIn(ID_MemWrite),
        .BranchIn(ID_Branch), .ALUSrcIn(ID_ALUSrc), .ShiftSrcIn(ID_ShiftSrc), .ZeroExtIn(ID_ZeroExt),
        .LinkIn(ID_Link), .MemSizeIn(ID_MemSize), .RegDstIn(ID_RegDst), .BranchTypeIn(ID_BranchType),
        .ALUControlIn(ID_ALUControl), .PCResultIn(ID_PCResult), .PCPlus4In(ID_PCAddResult),
        .ReadData1In(ID_ReadData1), .ReadData2In(ID_ReadData2), .ImmediateIn(ID_Immediate),
        .RtIn(ID_Instruction[20:16]), .RdIn(ID_Instruction[15:11]),
        .RegWriteOut(EX_RegWrite), .MemtoRegOut(EX_MemtoReg), .MemReadOut(EX_MemRead), .MemWriteOut(EX_MemWrite),
        .BranchOut(EX_Branch), .ALUSrcOut(EX_ALUSrc), .ShiftSrcOut(EX_ShiftSrc), .ZeroExtOut(EX_ZeroExt),
        .LinkOut(EX_Link), .MemSizeOut(EX_MemSize), .RegDstOut(EX_RegDst), .BranchTypeOut(EX_BranchType),
        .ALUControlOut(EX_ALUControl), .PCResultOut(EX_PCResult), .PCPlus4Out(EX_PCPlus4),
        .ReadData1Out(EX_ReadData1), .ReadData2Out(EX_ReadData2), .ImmediateOut(EX_Immediate),
        .RtOut(EX_Rt), .RdOut(EX_Rd));
 
    // EX - Thomas
    ExecuteStage ex(.PCPlus4(EX_PCPlus4), .ReadData1(EX_ReadData1), .ReadData2(EX_ReadData2),
        .Immediate(EX_Immediate), .Rt(EX_Rt), .Rd(EX_Rd), .ALUControl(EX_ALUControl), .ALUSrc(EX_ALUSrc),
        .ShiftSrc(EX_ShiftSrc), .ZeroExt(EX_ZeroExt), .RegDst(EX_RegDst), .Link(EX_Link),
        .BranchType(EX_BranchType), .ALUResult(EX_ALUResult), .Zero(), .BranchTarget(EX_BranchTarget),
        .BranchCond(EX_BranchCond), .WriteRegister(EX_WriteRegister), .MemWriteData(EX_MemWriteData));

    EX_MEM exmem(.Clk(Clk), .Reset(Reset),
        .RegWriteIn(EX_RegWrite), .MemtoRegIn(EX_MemtoReg), .MemReadIn(EX_MemRead), .MemWriteIn(EX_MemWrite),
        .BranchIn(EX_Branch), .MemSizeIn(EX_MemSize), .PCResultIn(EX_PCResult), .ALUResultIn(EX_ALUResult),
        .BranchTargetIn(EX_BranchTarget), .MemWriteDataIn(EX_MemWriteData), .BranchCondIn(EX_BranchCond),
        .WriteRegisterIn(EX_WriteRegister),
        .RegWriteOut(MEM_RegWrite), .MemtoRegOut(MEM_MemtoReg), .MemReadOut(MEM_MemRead), .MemWriteOut(MEM_MemWrite),
        .BranchOut(MEM_Branch), .MemSizeOut(MEM_MemSize), .PCResultOut(MEM_PCResult), .ALUResultOut(MEM_ALUResult),
        .BranchTargetOut(MEM_BranchTarget), .MemWriteDataOut(MEM_MemWriteData), .BranchCondOut(MEM_BranchCond),
        .WriteRegisterOut(MEM_WriteRegister));
 
    // MEM - Renae
    DataMemory dmem(.Address(MEM_ALUResult), .WriteData(MEM_MemWriteData), .Clk(Clk),
        .MemWrite(MEM_MemWrite), .MemRead(MEM_MemRead), .MemSize(MEM_MemSize), .ReadData(MEM_ReadData));
 
    MEM_WB memwb(.Clk(Clk), .Reset(Reset),
        .RegWriteIn(MEM_RegWrite), .MemtoRegIn(MEM_MemtoReg), .PCResultIn(MEM_PCResult),
        .ALUResultIn(MEM_ALUResult), .ReadDataIn(MEM_ReadData), .WriteRegisterIn(MEM_WriteRegister),
        .RegWriteOut(WB_RegWrite), .MemtoRegOut(WB_MemtoReg), .PCResultOut(WB_PCResult),
        .ALUResultOut(WB_ALUResult), .ReadDataOut(WB_ReadData), .WriteRegisterOut(WB_WriteRegister));
 
    // WB - Renae
    assign WB_WriteData = WB_MemtoReg ? WB_ReadData : WB_ALUResult;
    
    assign PC = WB_PCResult;
    assign WriteData = WB_RegWrite ? WB_WriteData : 32'd0;
 
endmodule
