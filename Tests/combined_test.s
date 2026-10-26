# ECE 369A Labs 4-5 unified ISA test program
# Sections: Thomas arithmetic -> Renae memory -> Karyna branches/jumps
# Original three source files remain unchanged.
# Register values and original PC annotations from individual test files shift after merging.
# This memory section matches the extended memory_test.mem (including signed loads/partial byte store).
# Five nops between test operations avoid pipeline data hazards.
# Memory section uses t0/t1/t2... and resets register inputs for Karyna section.
# IMPORTANT: This program is 175+ instructions; set simulation runtime accordingly.
.text
main:
# ----- THOMAS: Arithmetic / logic -----
addi $t0, $zero, 12
nop
nop
nop
nop
nop
addi $t1, $zero, 10
nop
nop
nop
nop
nop
add $t2, $t0, $t1
nop
nop
nop
nop
nop
sub $t3, $t0, $t1
nop
nop
nop
nop
nop
mul $t4, $t0, $t1
nop
nop
nop
nop
nop
and $t5, $t0, $t1
nop
nop
nop
nop
nop
andi $t6, $t0, 6
nop
nop
nop
nop
nop
or $t7, $t0, $t1
nop
nop
nop
nop
nop
ori $s0, $t0, 3
nop
nop
nop
nop
nop
xor $s1, $t0, $t1
nop
nop
nop
nop
nop
xori $s2, $t0, 5
nop
nop
nop
nop
nop
nor $s3, $t0, $t1
nop
nop
nop
nop
nop
sll $s4, $t1, 4
nop
nop
nop
nop
nop
srl $s5, $s4, 3
nop
nop
nop
nop
nop
slt $s6, $t1, $t0
nop
nop
nop
nop
nop
slt $s7, $t0, $t1
nop
nop
nop
nop
nop
addi $t8, $zero, -5
nop
nop
nop
nop
nop
slt $t9, $t8, $t0
nop
nop
nop
nop
nop
slti $t3, $t8, -1
nop
nop
nop
nop
nop
slti $t4, $t0, 5
nop
nop
nop
nop
nop
andi $t5, $t8, 65535
nop
nop
nop
nop
nop
ori $t6, $zero, 40000
nop
nop
nop
nop
nop
xori $t7, $t0, 65535
nop
nop
nop
nop
nop
add $s0, $t8, $t0
nop
nop
nop
nop
nop

# ----- RENAE: Data memory -----
addi $t0, $zero, 100
addi $t1, $zero, 42
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
addi $t1, $zero, -1
nop
nop
nop
nop
nop
sb $t1, 12($t0)
nop
nop
nop
nop
nop
lb $t5, 12($t0)
nop
nop
nop
nop
nop
sh $t1, 16($t0)
nop
nop
nop
nop
nop
lh $t6, 16($t0)
nop
nop
nop
nop
nop
addi $t0, $zero, 0x1234
nop
nop
nop
nop
nop
sw $t0, 120($zero)
nop
nop
nop
nop
nop
addi $t1, $zero, 0xAB
nop
nop
nop
nop
nop
sb $t1, 120($zero)
nop
nop
nop
nop
nop
lw $t2, 120($zero)
nop
nop
nop
nop
nop

# ----- KARYNA: Branch / jump -----
addi $t0, $zero, 5
addi $t1, $zero, -3
nop
nop
nop
beq $t0, $t0, B1
nop
nop
nop
addi $s0, $zero, 99
B1:
bne $t0, $zero, B2
nop
nop
nop
addi $s0, $zero, 99
B2:
bgez $t0, B3
nop
nop
nop
addi $s0, $zero, 99
B3:
bgtz $t0, B4
nop
nop
nop
addi $s0, $zero, 99
B4:
blez $t1, B5
nop
nop
nop
addi $s0, $zero, 99
B5:
bltz $t1, B6
nop
nop
nop
addi $s0, $zero, 99
B6:
j J1
nop
addi $s0, $zero, 99
J1:
jal FUNC
nop
addi $s1, $zero, 1
END:
j END
nop
FUNC:
nop
nop
jr $ra
nop
