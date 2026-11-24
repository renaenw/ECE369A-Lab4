# ECE 369A Lab 7 display test program (no nops) - Karyna Kuzhelnykova
#
# Writes (X, Y) into $v0 / $v1 in a loop, the way vbsme updates the current
# minimum, so the 7-segment display can be checked in post-implementation
# simulation before vbsme is ready:
#   left 4 digits  = $v0 = X (row)
#   right 4 digits = $v1 = Y (col)
#
# Loop k = 0..3:  X = k >> 1,  Y = (k + 1) >> 1
# Shown sequence (hex):  0000 0000   k = 0 (same as after reset)
#                        0000 0001   k = 1
#                        0001 0001   k = 2
#                        0001 0002   k = 3  <- final, stays on the display
# Each step changes only ONE coordinate, so a testbench that decodes the
# scanning display (Y digits first, then X digits) never sees a mixed value.
#
# Also exercises the Lab 7 datapath changes:
#   - $sp starts at 4092 on reset (setxy pushes/pops $ra on the stack)
#   - jal / jr $ra with delay slots, loop branch resolved in ID
#   - hazard stalls instead of nops (sw $ra right after addi $sp, jr right
#     after lw $ra, bne right after the slti that sets its operand)
#
# Each (X, Y) is held for about 66 datapath cycles (~13 ms at DivVal 10000),
# longer than one full display scan (8 digits x 1.31 ms = 10.5 ms), so a
# testbench watching only out7/en_out sees every value.
#
# Only instructions the Controller decodes are used (no pseudo-instructions).
# No branch or jump is placed in a delay slot.

        addi $s0, $zero, 0          # k = 0
loop:   srl  $a0, $s0, 1            # arg X = k >> 1
        addi $t3, $s0, 1
        jal  setxy
        srl  $a1, $t3, 1            # delay slot: arg Y = (k + 1) >> 1
        addi $s0, $s0, 1            # k++
        slti $t0, $s0, 4            # k < 4 ?
        bne  $t0, $zero, loop
        addi $t9, $t9, 1            # delay slot: count calls
done:   j    done                   # finished: final (X, Y) stays shown
        addi $t8, $t8, 1            # delay slot: heartbeat

# setxy: $v0 = $a0, $v1 = $a1, then wait so the display can show it.
# Saves $ra on the stack to check that $sp was set on reset.
setxy:  addi $sp, $sp, -4
        sw   $ra, 0($sp)            # stalls on the new $sp
        add  $v0, $a0, $zero        # X
        add  $v1, $a1, $zero        # Y
        addi $t1, $zero, 6          # hold count
wait:   addi $t1, $t1, -1
        bgtz $t1, wait
        addi $t2, $t2, 1            # delay slot
        lw   $ra, 0($sp)
        jr   $ra                    # stalls until lw writes $ra
        addi $sp, $sp, 4            # delay slot: pop
