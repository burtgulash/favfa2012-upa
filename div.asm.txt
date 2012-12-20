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
cond:	lb		$t0, 0($a0)
		beq		$t0, $0, endloop
		beq		$t0, 10, endloop
		bge		$t0, 'A', bigger
		sub		$t0, $t0, '0'
		b		endif
bigger:	sub		$t0, $t0, 'A'-10
endif: 	sll		$v0, $v0, 4
		addu	$v0, $v0, $t0
		addu	$a0, $a0, 1
		b		cond
endloop:jr		$ra


# void _to_hex(int n as $a0, void *buf as $a1, int len as $a2)
_to_hex:
		move	$v0, $a1
		move	$t0, $a2
		addu 	$v0, $v0, $t0
		subu	$v0, $v0, 1
		sb		$0, ($v0)
loop:	subu	$v0, $v0, 1
		and		$t1, $a0, 15
		blt		$t1, 10, small
		add		$t1, 'A'-10
		b		store
small:	add		$t1, '0'
store:	sb		$t1, ($v0)
		srl		$a0, $a0, 4
		bgt		$a0, $0, loop
		jr 		$ra


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
L1: 	bgt		$s1, $t0, L2		# if (x > (a >> 1)) goto L2
		sll		$s1, $s1, 1			# x <<= 1
		b		L1					# goto L1
L2: 	blt		$s1, $a1, L4		# if (x < b) goto L4
		blt 	$a0, $s1, L3		# if (a < x) goto L3
		or		$s0, $s0, 1			# q |= 1
		sub		$a0, $a0, $s1		# a -= x
L3: 	srl		$s1, $s1, 1			# x >>= 1
		sll		$s0, $s0, 1			# q <<= 1
		b 		L2					# goto L2
L4: 	srl		$s0, $s0, 1			# q >>= 1
		move	$v0, $s0			# quotient = q
		move	$v1, $a0			# remainder = a

	
		# -----------------
		lw		$s0, 0($sp)
		lw		$s1, 4($sp)
		addu	$sp, $sp, 8 

		jr 		$ra
	

main:
		# get dividend
		la		$a0, delenec
		li		$v0, 4
		syscall
		la		$a0, buf
		lw		$a1, len
		li		$v0, 8
		syscall
		jal 	_from_hex
		move	$s0, $v0
		

		# get divisor
		la		$a0, delitel
		li		$v0, 4
		syscall
		la		$a0, buf
		lw		$a1, len
		li		$v0, 8
		syscall
		jal 	_from_hex
		move	$s1, $v0

		# TODO remove
		move	$a0, $s0
		li		$v0, 1
		syscall
		la		$a0, newline
		li		$v0, 4
		syscall
		move	$a0, $s1
		li		$v0, 1
		syscall
		la		$a0, newline
		li		$v0, 4
		syscall
		# TODO remove

		# call divide
		move	$a0, $s0
		move	$a1, $s1
		jal		_div
		move 	$s0, $v0	# quotient
		move	$s1, $v1	# remainder


		# print hex quotient
		la		$a0, podil
		li		$v0, 4
		syscall
		move	$a0, $s0
		la		$a1, buf
		lw		$a2, len
		jal		_to_hex
		move	$a0, $v0
		li	 	$v0, 4
		syscall
		la		$a0, newline
		li		$v0, 4
		syscall

		# print hex quotient
		la		$a0, zbytek
		li		$v0, 4
		syscall
		move	$a0, $s1
		la		$a1, buf
		lw		$a2, len
		jal		_to_hex
		move	$a0, $v0
		li	 	$v0, 4
		syscall
		la		$a0, newline
		li		$v0, 4
		syscall

		# EXIT
		li		$v0, 10
		syscall

