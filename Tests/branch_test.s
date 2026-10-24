# ECE 369A - Lab 4
# Branch and jump test
# Karyna Kuzhelnykova 100%
#
# Expected WriteData:
#   PC=0  -> 5         $t0
#   PC=4  -> -3        $t1
#   PC=152 -> 160      jal writes $ra = PC+8
#   PC=160 -> 1        back from jr $ra: all tests passed
 
.text
main:
    addi $t0, $zero, 5
    addi $t1, $zero, -3
    nop
    nop
    nop
    beq  $t0, $t0, B1
    nop
    nop
    nop
    addi $s0, $zero, 99
B1:
    bne  $t0, $zero, B2
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
    j    J1
    nop
    addi $s0, $zero, 99
J1:
    jal  FUNC
    nop
    addi $s1, $zero, 1
END:
    j    END
    nop
FUNC:
    nop
    nop
    jr   $ra
    nop
