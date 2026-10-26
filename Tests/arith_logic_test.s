# ECE369 Labs 4-5 - Arithmetic and logical test code (Person A)
# Thomas Shing 100%
#
# Covers: add addi sub mul and andi or ori nor xor xori sll srl slt slti
# Five nops follow every instruction because the datapath has no hazard
# detection. Comments give the PC and the value written to the register
# file: decimal (post-routing simulation) and hex (FPGA display).
# PCs assume this block starts at address 0; they shift if the block is
# merged after other code.

.text
main:
	addi $t0, $zero, 12     # PC=0    t0 = 12                                      write 12 (0x0000000C)
	nop
	nop
	nop
	nop
	nop
	addi $t1, $zero, 10     # PC=24   t1 = 10                                      write 10 (0x0000000A)
	nop
	nop
	nop
	nop
	nop
	add  $t2, $t0, $t1      # PC=48   t2 = 12 + 10                                 write 22 (0x00000016)
	nop
	nop
	nop
	nop
	nop
	sub  $t3, $t0, $t1      # PC=72   t3 = 12 - 10                                 write 2 (0x00000002)
	nop
	nop
	nop
	nop
	nop
	mul  $t4, $t0, $t1      # PC=96   t4 = 12 * 10                                 write 120 (0x00000078)
	nop
	nop
	nop
	nop
	nop
	and  $t5, $t0, $t1      # PC=120  t5 = 1100 & 1010                             write 8 (0x00000008)
	nop
	nop
	nop
	nop
	nop
	andi $t6, $t0, 6        # PC=144  t6 = 1100 & 0110                             write 4 (0x00000004)
	nop
	nop
	nop
	nop
	nop
	or   $t7, $t0, $t1      # PC=168  t7 = 1100 | 1010                             write 14 (0x0000000E)
	nop
	nop
	nop
	nop
	nop
	ori  $s0, $t0, 3        # PC=192  s0 = 1100 | 0011                             write 15 (0x0000000F)
	nop
	nop
	nop
	nop
	nop
	xor  $s1, $t0, $t1      # PC=216  s1 = 1100 ^ 1010                             write 6 (0x00000006)
	nop
	nop
	nop
	nop
	nop
	xori $s2, $t0, 5        # PC=240  s2 = 1100 ^ 0101                             write 9 (0x00000009)
	nop
	nop
	nop
	nop
	nop
	nor  $s3, $t0, $t1      # PC=264  s3 = ~(1100 | 1010)                          write -15 (0xFFFFFFF1)
	nop
	nop
	nop
	nop
	nop
	sll  $s4, $t1, 4        # PC=288  s4 = 10 << 4                                 write 160 (0x000000A0)
	nop
	nop
	nop
	nop
	nop
	srl  $s5, $s4, 3        # PC=312  s5 = 160 >> 3                                write 20 (0x00000014)
	nop
	nop
	nop
	nop
	nop
	slt  $s6, $t1, $t0      # PC=336  s6 = (10 < 12)                               write 1 (0x00000001)
	nop
	nop
	nop
	nop
	nop
	slt  $s7, $t0, $t1      # PC=360  s7 = (12 < 10)                               write 0 (0x00000000)
	nop
	nop
	nop
	nop
	nop
	addi $t8, $zero, -5     # PC=384  t8 = -5                                      write -5 (0xFFFFFFFB)
	nop
	nop
	nop
	nop
	nop
	slt  $t9, $t8, $t0      # PC=408  t9 = (-5 < 12) signed compare                write 1 (0x00000001)
	nop
	nop
	nop
	nop
	nop
	slti $t3, $t8, -1       # PC=432  t3 = (-5 < -1) signed compare                write 1 (0x00000001)
	nop
	nop
	nop
	nop
	nop
	slti $t4, $t0, 5        # PC=456  t4 = (12 < 5)                                write 0 (0x00000000)
	nop
	nop
	nop
	nop
	nop
	andi $t5, $t8, 65535    # PC=480  t5 = 0xFFFFFFFB & 0x0000FFFF (zero extend)   write 65531 (0x0000FFFB)
	nop
	nop
	nop
	nop
	nop
	ori  $t6, $zero, 40000  # PC=504  t6 = 40000 (zero extend, not 0xFFFF9C40)     write 40000 (0x00009C40)
	nop
	nop
	nop
	nop
	nop
	xori $t7, $t0, 65535    # PC=528  t7 = 12 ^ 0x0000FFFF (zero extend)           write 65523 (0x0000FFF3)
	nop
	nop
	nop
	nop
	nop
	add  $s0, $t8, $t0      # PC=552  s0 = -5 + 12                                 write 7 (0x00000007)
	nop
	nop
	nop
	nop
	nop
