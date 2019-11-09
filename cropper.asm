#name:	Thomas Wright
#studentID:	260769898

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
.align 2
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 10
x2: .word 15
y1: .word 1
y2: .word 6
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line
header: .asciiz "P2\n7 25\n15\n" 
error:	.asciiz "The file is not acceptable!\n"
space: .asciiz " "
array:	.space 2048

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
	addi $sp $sp, -24
	la $a0, x1
	la $a1, x2
	la $a2, y1
	la $a3, y2
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $a3, 12($sp)
	la $t0, buffer
	la $t1, newbuff
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	jal crop
	addi $sp, $sp, 24
	
	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
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
		
makearray:	la $t0, buffer	# this turns the buffer into a 24x7 int array
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


crop:	la $s0, buffer
	la $s1, newbuff
	lw $a2, ($a2)
	lw $a0, ($a0)
	lw $a1, ($a1)
	lw $a3, ($a3)
	li $t3, 0
	li $t4, 0
	mul $t0, $a2, 96	
	mul $t1, $a0, 4
	add $t2, $t0, $t1
	add $s0, $s0, $t2	# s0 points to our starting point following the 1D matrix math highlighted in the assignment
	move $s2, $s0	# s2 will always point to start
	
start:	lw $t0, 0($s0)
	bge $t0, 10, td		# a two digit
	j od
td:	li $t1, 49
	sb $t1, 0($s1)		# storing the 1
	addi $t1, $t0, 38
	sb $t1, 1($s1)		# storing the second digit
	li $t1, 32
	sb $t1, 2($s1)		# storing a space
	j ahead
od:	li $t1, 32
	sb $t1, 0($s1)		# storing a space
	addi $t1, $t0, 48
	sb $t1, 1($s1)		# storing the digit
	li $t1, 32
	sb $t1, 2($s1)		# storing a space
ahead:	addi $s0, $s0, 4	# this is correct offset
	addi $t3, $t3, 1
	addi $s1, $s1, 3	# moving s3 three 
	bge $t3, $a1, next	# newline
	j start
next:	li $t3, 10		# adding a newline
	sb $t3, 0($s1)
	li $t3, 0
	addi $t4, $t4, 1
	addi $s1, $s1, 1
	mul $t5, $t4, 96
	add, $s0, $s2, $t5	# issue with the jump
	sub $t9, $a3, $a2
	bgt $t4, $t9, done
	j start
	
done: jr $ra
	
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.

writefile:	la $a3, ($a1)
		li $v0, 13	# opening the file system call
		li $a1, 1	# 1 flag for write
		li $a2, 0	# mode ignored
		syscall
		blt $v0, $zero, errors
		move $s0, $v0	# saving the file descripor
		
		lw $t5, x1
		lw $t6, x2
		lw $t7, y1
		lw $t8, y2
		la $s1, headerbuff
		addi $t0, $zero, 80
		sb $t0, 0($s1)		# storing the P
		addi $t0, $zero, 50
		sb $t0, 1($s1)		# storing the 2
		addi $t0, $zero, 10
		sb $t0, 2($s1)		# storing the \n
		li $t2, 0
		sub $t2, $t8, $t7
		addi $t2, $t2, 1
		li $t1, 0
		sub $t1, $t6, $t5
		addi $t1, $t1, 1
		bge $t1, 10, dig2
dig1:		addi $t1, $t1, 48
		sb $t1, 3($s1)		# storing the length
		addi $t0, $zero, 32
		sb $t0, 4($s1)		# storing the space
		addi $t2, $t2, 48
		sb $t2, 5($s1)		# storing the height
		addi $t0, $zero, 10
		sb $t0, 6($s1)		# storing the \n
		addi $t0, $zero, 49
		sb $t0, 7($s1)		# storing the \n
		addi $t0, $zero, 53
		sb $t0, 8($s1)		# storing the \n
		addi $t0, $zero, 10
		sb $t0, 9($s1)		# storing the \n
			
		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, headerbuff	# loading address of hardcoded image header
		li $a2, 10	# max chars to read
		syscall
		blt $v0, $zero, errors
	
		j finito
		
dig2:		li $t9, 10
		div $t1, $t9		
		mflo $t7		# high digit
		mfhi $t8		# low digit
		addi $t7, $t7, 48
		sb $t7, 3($s1)		# storing the low digit
		addi $t8, $t8, 48
		sb $t8, 4($s1)		# storing the high digit
		addi $t0, $zero, 32
		sb $t0, 5($s1)		# storing the space
		addi $t2, $t2, 48
		sb $t2, 6($s1)		# storing the height
		addi $t0, $zero, 10
		sb $t0, 7($s1)		# storing the \n
		addi $t0, $zero, 49
		sb $t0, 8($s1)		# storing the 1
		addi $t0, $zero, 53
		sb $t0, 9($s1)		# storing the 5
		addi $t0, $zero, 10
		sb $t0, 10($s1)		# storing the \n

		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, headerbuff	# loading address of hardcoded image header
		li $a2, 11	# max chars to read
		syscall
		blt $v0, $zero, errors
		
		j finito
				
finito:		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, newbuff	# loading address of input buffer
		li $a2, 2048	# max chars to read
		syscall
		blt $v0, $zero, errors
		
		li $v0, 16	# close file syscall
		la $a0, ($s0)
		syscall
	
		jr $ra

errors:		li $v0, 4	#print
		la $a0, error
		syscall	
		nop
