	.text

_div:
	addi	$sp, $sp, -8
	sw		$s0, 0($sp)
	sw		$s1, 4($sp)
	nop 
	nop
	# -----------------

	# a = $a0
	# b = $a1
	# q = $s0
	# x = $s1

	li		$s0, 0				# q = 0
	move	$s1, $a1			# x = b
	

	srl		$t0, $a0, 1			# a >> 1
L1:
	bgt		$s1, $t0, L2		# if (x > (a >> 1)) goto L2
	nop
	sll		$s1, $s1, 1			# x <<= 1
	b		L1					# goto L1
	nop
L2:
	blt		$s1, $a1, L4		# if (x < b) goto L4
	nop
	blt 	$a0, $s1, L3		# if (a < x) goto L3
	nop
	or		$s0, $s0, 1			# q |= 1
	sub		$a0, $a0, $s1		# a -= x
L3:
	srl		$s1, $s1, 1			# x >>= 1
	sll		$s0, $s0, 1			# q <<= 1
	b 		L2					# goto L2
	nop
L4:
	srl		$s0, $s0, 1			# q >>= 1

	move	$v0, $s0			# quotient = q
	move	$v1, $a0			# remainder = a

	
	# -----------------
	lw		$s0, 0($sp)
	lw		$s1, 4($sp)
	addi	$sp, $sp, 8 

	jr 		$ra
	nop
	

main:
	# load a
#	li		$v0, 5
#	syscall
#	move	$a0, $v0
#
#	# load b
#	li		$v0, 5
#	syscall
#	move	$a1, $v1

	li		$a0, 115
	li		$a1, 10
	nop
	jal		_div
	nop

	# PRINT q
	move	$a0, $v0
	li	 	$v0, 1
	syscall

	# PRINT r
	move	$a0, $v1
	li	 	$v0, 1
	syscall

	# EXIT syscall
	li		$v0, 10
	syscall
