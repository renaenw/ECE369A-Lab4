# ECE 369A — Labs 4 & 5

University of Arizona — Fundamentals of Computer Organization

## Project Overview
This project focuses on building and testing a five-stage pipelined MIPS processor using Verilog and Vivado 2022.2.

The processor includes the following stages:
- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)

## Team Responsibilities

**Person A — Execute / Control**
- ALU and Controller
- Execute stage wiring
- Arithmetic and logical instruction testing
- FPGA display and clock divider

**Person B — Fetch / Decode**
- Register File
- Pipeline registers
- Instruction Fetch and Decode wiring
- Branch and jump logic
- Top-level testbench
- FPGA constraints and bitstream

**Person C — Memory / Write Back**
- Data Memory and testbench
- Controller testbench
- Memory and Write-Back stage wiring
- Byte and halfword memory operations
- Memory initialization and load/store testing
- Final test program integration
- FPGA output verification

## Project Structure

- `components/` — Reusable datapath components from Lab 3
- `testbenches/` — Component and controller testbenches
- `pipeline/` — Pipeline registers and top-level datapath
- `controller/` — Controller implementation
- `tests/` — Assembly programs and memory initialization files

## Development

Software: Vivado 2022.2  
Language: Verilog HDL  
Target FPGA: Artix-7 (xc7a100tcsg324-1)

Components will be tested individually before integration into the complete processor.

## Status

Lab 4 development in progress. Existing Lab 3 components will be reviewed and verified before integration.

## Lab 6 — Hazard Detection

Design notes for the D2L submission comment:
- Number of pipeline stages: 5 (IF, ID, EX, MEM, WB)
- Branch decision and resolution stage: ID, with one branch delay slot
  (the instruction after a branch / j / jal / jr always executes; jal writes $ra = PC + 8)

Test program (`Tests/instruction_memory.s` / `.mem`): no nops, covers every
instruction in Table 1 with dependent chains (back-to-back RAW on rs and rt,
lw-use, sw/sh/sb of fresh values, every branch on a fresh value taken and not
taken, zero edge cases, jal/jr). It does not depend on `data_memory.mem`.
The comments give `[PC] value written` for every instruction.

Testbench (`TestBenches/Lab6_tb.v`): drives `Datapath` through its ports only,
so it works in post-route simulation. It checks every register write against
the expected trace and prints the cycle count. Set `CHECK = 0` to only print
the trace when running a different program (e.g. the TA's).

Register file note: writes happen on the rising edge at the end of WB and
reads are latched on the falling edge, so an instruction in ID must wait
while its producer is in EX, MEM **or WB**.
