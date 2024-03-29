	.data

newline:	.asciiz		"\n"
delenec:	.asciiz		"delenec: "
delitel:	.asciiz		"delitel: "
podil:		.asciiz		"podil: "
zbytek:		.asciiz		"zbytek: "
buf:		.space 		33
len:		.word 		33

	.text

# int _from_hex(void *buf as $a0)
_from_hex:
		move	$v0, $0
cond:	lbu		$t0, 0($a0)
		nop
		beq		$t0, $0, endloop
		nop
		beq		$t0, 10, endloop
		nop
		bgeu	$t0, 'A', bigger
		nop
		subu	$t0, $t0, '0'
		b		endif
		nop
bigger:	subu	$t0, $t0, 'A'-10
endif: 	sll		$v0, $v0, 4
		addu	$v0, $v0, $t0
		addu	$a0, $a0, 1
		b		cond
		nop
endloop:jr		$ra
		nop


# void _to_hex(int n as $a0, void *buf as $a1, int len as $a2)
_to_hex:
		move	$v0, $a1
		move	$t0, $a2
		addu 	$v0, $v0, $t0
		subu	$v0, $v0, 1
		sb		$0, ($v0)
loop:	subu	$v0, $v0, 1
		and		$t1, $a0, 15
		bltu	$t1, 10, small
		nop
		addu	$t1, 'A'-10
		b		store
		nop
small:	addu	$t1, '0'
store:	sb		$t1, ($v0)
		srl		$a0, $a0, 4
		bgtu	$a0, $0, loop
		nop
		jr 		$ra
		nop


_div:
		subu	$sp, $sp, 8
		sw		$s0, 0($sp)
		sw		$s1, 4($sp)
		# -----------------

		# a = $a0
		# b = $a1
		# q = $s0
		# x = $s1

		li		$s0, 0				# q = 0
		move	$s1, $a1			# x = b

		srl		$t0, $a0, 1			# a >> 1
L1: 	bgtu	$s1, $t0, L2		# if (x > (a >> 1)) goto L2
		nop
		sll		$s1, $s1, 1			# x <<= 1
		b		L1					# goto L1
		nop
L2: 	bltu	$s1, $a1, L4		# if (x < b) goto L4
		nop
		bltu 	$a0, $s1, L3		# if (a < x) goto L3
		nop
		or		$s0, $s0, 1			# q |= 1
		subu	$a0, $a0, $s1		# a -= x
L3: 	srl		$s1, $s1, 1			# x >>= 1
		sll		$s0, $s0, 1			# q <<= 1
		b 		L2					# goto L2
		nop
L4: 	srl		$s0, $s0, 1			# q >>= 1
		move	$v0, $s0			# quotient = q
		move	$v1, $a0			# remainder = a

	
		# -----------------
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addu	$sp, $sp, 8 

		jr 		$ra
		nop
	

main:
		# get dividend
		la		$a0, delenec
		li		$v0, 4
		nop
		syscall
		la		$a0, buf
		lw		$a1, len
		li		$v0, 8
		nop
		syscall
		jal 	_from_hex
		nop
		move	$s0, $v0
		

		# get divisor
		la		$a0, delitel
		li		$v0, 4
		nop
		syscall
		la		$a0, buf
		lw		$a1, len
		li		$v0, 8
		nop
		syscall
		jal 	_from_hex
		nop
		move	$s1, $v0


		# call divide
		move	$a0, $s0
		move	$a1, $s1
		jal		_div
		nop
		move 	$s0, $v0	# quotient
		move	$s1, $v1	# remainder


		# print hex quotient
		la		$a0, podil
		li		$v0, 4
		nop
		syscall
		move	$a0, $s0
		la		$a1, buf
		lw		$a2, len
		jal		_to_hex
		nop
		move	$a0, $v0
		li	 	$v0, 4
		nop
		syscall
		la		$a0, newline
		li		$v0, 4
		nop
		syscall

		# print hex remainder
		la		$a0, zbytek
		li		$v0, 4
		nop
		syscall
		move	$a0, $s1
		la		$a1, buf
		lw		$a2, len
		jal		_to_hex
		nop
		move	$a0, $v0
		li	 	$v0, 4
		nop
		syscall
		la		$a0, newline
		li		$v0, 4
		nop
		syscall

		# EXIT
		li		$v0, 10
		nop
		syscall

