# ECE 369A - Lab 4
# Memory Instruction Test
# Renae Weiss
#
# Tests word, halfword, and byte memory operations.
# Five NOPs are placed between dependent instructions
# because our processor does not have hazard detection.

addi $t0, $zero, 100

addi $t1, $zero, 42
nop
nop
nop
nop
nop

sw $t1, 0($t0)
nop
nop
nop
nop
nop

lw $t2, 0($t0)
nop
nop
nop
nop
nop

sb $t1, 4($t0)
nop
nop
nop
nop
nop

lb $t3, 4($t0)
nop
nop
nop
nop
nop

sh $t1, 8($t0)
nop
nop
nop
nop
nop

lh $t4, 8($t0)
nop
nop
nop
nop
nop

# Expected results:
# $t2 = 42 (lw)
# $t3 = 42 (lb)
# $t4 = 42 (lh)
