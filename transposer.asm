.data

input:	.asciiz "test1.txt"
output:	.asciiz "transposed.pgm"	#used as output
.align 2
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 
space: .asciiz " "
newline:	.asciiz "\n"
header: .asciiz "P2\n7 24\n15\n"	# hardcoded header
error:	.asciiz "The file is not acceptable!\n"
array:	.space 2048
	.text
	.globl main

main:	la $a0,input 		#readfile takes $a0 as input
	jal readfile
	
	
	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
    	jal transpose


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:	li $v0, 13	# opening the file system call
		li $a1, 0	# 0 flag for read
		li $a2, 0	# mode ignored
		syscall
		move $s0, $v0	# saving the file descripor
		blt $v0, $zero, errors
		
		li $v0, 14	# readfile syscall
		move $a0, $s0	# loading file descriptor into arg0
		la $a1, array	# loading address of input buffer
		li $a2, 2048	# max chars to read
		syscall
		move $s0, $v0	# saving the file descripor
		blt $v0, $zero, errors
		
		li $v0, 16	# close file syscall
		move $a0, $s0
		syscall
		

makearray:	la $t0, buffer	# making an int array
		la $t1, array
		li $t9, 0
ma:		bge $t9, 168, return
		lb $t3, 0($t1)
		blt $t3, 48, cont
		bgt, $t3, 57, cont
		lb $t4, 1($t1)
		beq $t4, 0xa, onedig
		beq $t4, 0x20, onedig
		addi $t4, $t4, -38
		sw $t4, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 2
		addi $t9, $t9, 1
		j ma
		
onedig:		addi $t3, $t3, -48
		sw $t3, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		addi $t9, $t9, 1
		j ma
cont:		addi $t1, $t1, 1
		j ma
return:		jr $ra
		
 
transpose:	move $s0, $a0
		move $s1, $a1
		li $t5, 32	# t5 is a space
		li $t6, 10	# t6 is a newline
		li $t3, 0
		li $t4, 0
trans:		lw $t0, 0($s0)
		bge $t0, 10, td		# adding two digit int
		j od			# adding one digit int
td:		li $t1, 49
		sb $t1, 0($s1)
		addi $t1, $t0, 38
		sb $t1, 1($s1)
		li $t1, 32
		sb $t1, 2($s1)
		j ahead
od:		li $t1, 32
		sb $t1, 0($s1)
		addi $t1, $t0, 48
		sb $t1, 1($s1)
		li $t1, 32
		sb $t1, 2($s1)
ahead:		addi $s0, $s0, 96	# this is correct offset
		addi $t3, $t3, 1
		addi $t4, $t4, 3	# moving 3 ahead
		addi $s1, $s1, 3	# moving s3 three forward **or two?**	
		bge $t3, 6, next	# 6 or 7
		bge $t4, 453, done	# done if gone through everything
		j trans
next:		li $t3, 48
		sb $t3, 0($s1)
		li $t3, 0
		sb $t6, 1($s1)
		addi $s1, $s1, 2
		addi, $s0, $s0, -572	# issue with the jump
		addi $t4, $t4, 1
		bge $t4, 453, done
		j trans
done:	jr $ra
		
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!

writefile:	la $a3, ($a1)
		li $v0, 13	# opening the file system call
		li $a1, 1	# 1 flag for write
		li $a2, 0	# mode ignored
		syscall
		#blt $v0, $zero, errors
		move $s0, $v0	# saving the file descripor
		
		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, header	# loading address of hardcoded image header
		li $a2, 11	# max chars to read
		syscall
		#blt $v0, $zero, errors
		
		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, newbuff	# loading address of input buffer
		li $a2, 2048	# max chars to read
		syscall
		#blt $v0, $zero, errors
		
		li $v0, 16	# close file syscall
		la $a0, ($s0)
		syscall
	
		jr $ra
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

errors:		li $v0, 4	#print
		la $a0, error
		syscall	
		nop
