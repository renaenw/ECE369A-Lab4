# ECE 369A Lab 6 test program (no nops) - Thomas Shing
#
# Every instruction in Table 1 of Labs 4-5, arranged as long dependent
# chains so the hazard detection unit has to stall instead of nops:
#   - back-to-back RAW on rs and on rt (distance 1, 2 and 3)
#   - lw followed right away by a use (ALU, sw, lw base, branch)
#   - sw / sh / sb of a value computed by the instruction just before
#   - every branch on a register written by the instruction just before,
#     both taken and not taken, plus the zero edge cases
#   - jr on a register written just before (jal -> jr $ra, addi -> jr)
#
# Branch/jump rules this program is written for (Lab 6 design):
#   - branches and jumps are resolved in ID
#   - ONE delay slot: the instruction after a branch/j/jal/jr always runs
#   - jal writes $ra = PC + 8 (the instruction after the delay slot)
# No branch or jump is ever placed in a delay slot.
#
# The program does not depend on data_memory.mem: everything it loads it
# stores first (data area starts at byte address 256).
# Reaching "fail" means a branch went the wrong way: it writes 0xBAD (2989).
# The program ends in the "done" loop, where no more registers are written.
# PC and the value written are in the comments: [PC] value
.text
main:
# ---------- arithmetic / logic chain ----------
addi $t0, $zero, 12        # [0] 12         t0 = 12
addi $t1, $t0, -2          # [4] 10         rs dist 1
add  $t2, $t0, $t1         # [8] 22         rs dist 2, rt dist 1
sub  $t3, $t2, $t0         # [12] 10        rs dist 1, rt dist 3
mul  $t4, $t3, $t2         # [16] 220       rs dist 1, rt dist 2
or   $t5, $t4, $t1         # [20] 222       rs dist 1
and  $t6, $t5, $t4         # [24] 220       rs dist 1, rt dist 2
xor  $t7, $t6, $t5         # [28] 2         rs dist 1, rt dist 2
nor  $t8, $t7, $zero       # [32] -3        rs dist 1
andi $t9, $t8, 65295       # [36] 65293     rs dist 1, zero-extended immediate 0xFF0F
ori  $s1, $t9, 240         # [40] 65533     rs dist 1
xori $s2, $s1, 3855        # [44] 61682     rs dist 1
sll  $s3, $s2, 4           # [48] 986912    rt dist 1 (shifts read rt)
srl  $s4, $s3, 8           # [52] 3855      rt dist 1
slt  $s5, $t8, $s4         # [56] 1         rt dist 1, signed: -3 < 3855
slti $s6, $s5, 2           # [60] 1         rs dist 1
slt  $s7, $s4, $t8         # [64] 0         false -> writes 0
add  $v0, $s7, $s6         # [68] 1         rs dist 1, rt dist 2
# ---------- memory: lw-use and sw of fresh values ----------
addi $s0, $zero, 256       # [72] 256       data base address
sw   $t4, 0($s0)           # [76]           base (rs) dist 1
addi $a0, $t4, -20         # [80] 200
sw   $a0, 4($s0)           # [84]           stored value (rt) dist 1
lw   $a1, 4($s0)           # [88] 200       load right after the store
add  $a2, $a1, $a0         # [92] 400       lw-use on rs, dist 1
lw   $a3, 0($s0)           # [96] 220
sub  $v1, $a2, $a3         # [100] 180      lw-use on rt, dist 1
lw   $t0, 4($s0)           # [104] 200
addi $t1, $zero, 7         # [108] 7
add  $t2, $t1, $t0         # [112] 207      lw-use on rt, dist 2
sw   $t2, 8($s0)           # [116]          rt dist 1
lw   $t3, 8($s0)           # [120] 207
sw   $t3, 12($s0)          # [124]          lw then sw of the loaded value
lw   $t4, 12($s0)          # [128] 207
sw   $s0, 16($s0)          # [132]
lw   $t5, 16($s0)          # [136] 256      t5 = 256
lw   $t6, 4($t5)           # [140] 200      lw base from lw, dist 1
# ---------- byte / half stores and loads ----------
addi $t7, $zero, -31       # [144] -31      0xFFFFFFE1
sb   $t7, 20($s0)          # [148]          byte 0 = E1
addi $t8, $zero, 32602     # [152] 32602    0x7F5A
sb   $t8, 21($s0)          # [156]          byte 1 = 5A
addi $t9, $zero, -32768    # [160] -32768   0xFFFF8000
sh   $t9, 22($s0)          # [164]          upper half = 8000 -> word 0x80005AE1
lw   $s1, 20($s0)          # [168] -2147460383
lb   $s2, 20($s0)          # [172] -31      E1 -> -31
lb   $s3, 21($s0)          # [176] 90       5A -> 90
lh   $s4, 22($s0)          # [180] -32768   8000 -> -32768
lh   $s5, 20($s0)          # [184] 23265    5AE1 -> 23265
lb   $s6, 23($s0)          # [188] -128     80 -> -128
add  $s7, $s6, $s5         # [192] 23137    lb/lh use, dist 1 and 2
sh   $s7, 24($s0)          # [196]          rt dist 1
lh   $v0, 24($s0)          # [200] 23137
sb   $v0, 28($s0)          # [204]          lh then sb of the loaded value
lb   $v1, 28($s0)          # [208] 97       0x61 -> 97
# ---------- branches taken, on fresh values ----------
addi $t0, $zero, 5         # [212] 5
addi $t1, $zero, 5         # [216] 5
beq  $t0, $t1, beq_ok      # [220]          taken, rt dist 1, rs dist 2
addi $t2, $t0, 1           # [224] 6        delay slot: runs
j    fail                  # [228]          skipped
beq_ok:
add  $t3, $t2, $t0         # [232] 11       uses the delay slot result
bne  $t3, $t2, bne_ok      # [236]          taken, rs dist 1
sub  $t4, $t3, $t2         # [240] 5        delay slot
j    fail                  # [244]
bne_ok:
sw   $t4, 32($s0)          # [248]
lw   $t5, 32($s0)          # [252] 5
bgtz $t5, bgtz_ok          # [256]          taken, lw -> branch dist 1
addi $t6, $t5, -10         # [260] -5       delay slot
j    fail                  # [264]
bgtz_ok:
bltz $t6, bltz_ok          # [268]          taken, rs written by the delay slot
addi $t7, $t6, 3           # [272] -2       delay slot
j    fail                  # [276]
bltz_ok:
blez $t7, blez_ok          # [280]          taken, rs dist 1
addi $t8, $t7, 9           # [284] 7        delay slot
j    fail                  # [288]
blez_ok:
bgez $t8, bgez_ok          # [292]          taken, rs dist 1
addi $t9, $t8, -9          # [296] -2       delay slot
j    fail                  # [300]
bgez_ok:
# ---------- branches not taken, on fresh values ----------
bgez $t9, fail             # [304]          -2: not taken
addi $a0, $t9, 2           # [308] 0        delay slot, writes 0
bgtz $a0, fail             # [312]          0: not taken
addi $a1, $a0, 3           # [316] 3        delay slot
bltz $a0, fail             # [320]          0: not taken
addi $a2, $a1, 4           # [324] 7        delay slot
blez $a2, fail             # [328]          7: not taken
addi $a3, $a2, -7          # [332] 0        delay slot, writes 0
beq  $a2, $a1, fail        # [336]          7 != 3: not taken
addi $v0, $a1, 1           # [340] 4        delay slot
addi $v1, $a1, 1           # [344] 4
bne  $v0, $v1, fail        # [348]          4 == 4: not taken
sub  $s1, $v1, $a1         # [352] 1        delay slot
# ---------- zero edge cases, taken ----------
bgez $a3, z1               # [356]          0: taken
addi $s2, $s1, 1           # [360] 2        delay slot
j    fail                  # [364]
z1:
blez $a3, z2               # [368]          0: taken
addi $s3, $s2, 1           # [372] 3        delay slot
j    fail                  # [376]
z2:
# ---------- branch on two loaded values ----------
sw   $s3, 36($s0)          # [380]
lw   $s4, 36($s0)          # [384] 3
lw   $s5, 32($s0)          # [388] 5
beq  $s4, $s5, fail        # [392]          3 != 5: not taken, both operands loaded
addi $s6, $s4, 2           # [396] 5        delay slot
lw   $s7, 32($s0)          # [400] 5
beq  $s7, $s6, lw_beq_ok   # [404]          5 == 5: taken, lw -> branch dist 1
addi $s5, $s7, 1           # [408] 6        delay slot
j    fail                  # [412]
lw_beq_ok:
# ---------- backward branch loop ----------
addi $t0, $zero, 3         # [416] 3
addi $t1, $zero, 100       # [420] 100
loop:
addi $t0, $t0, -1          # [424] 2, 1, 0
bne  $t0, $zero, loop      # [428]          backward, rs dist 1
addi $t1, $t1, 10          # [432] 110, 120, 130  delay slot, runs every time
# ---------- jal / jr ----------
jal  func                  # [436] 444      $ra = PC + 8
addi $a0, $zero, 77        # [440] 77       delay slot of jal (runs before func)
add  $a1, $v0, $a0         # [444] 155      after return: 78 + 77
addi $t2, $zero, 472       # [448] 472      address of jr_target
jr   $t2                   # [452]          jump register, rs dist 1
addi $a2, $a1, 1           # [456] 156      delay slot
j    fail                  # [460]
func:
jr   $ra                   # [464]          $ra written by jal 2 instructions ago
addi $v0, $a0, 1           # [468] 78       delay slot: 78
jr_target:
mul  $a3, $a2, $t1         # [472] 20280    156 * 130
srl  $t3, $a3, 2           # [476] 5070     rt dist 1
j    done                  # [480]
sub  $t4, $t3, $a2         # [484] 4914     delay slot of j
fail:
addi $v1, $zero, 2989      # [488]          0xBAD: a branch went the wrong way
j    fail                  # [492]
nop                        # [496]
done:
j    done                  # [500]          end: loop here, nothing else is written
nop                        # [504]
