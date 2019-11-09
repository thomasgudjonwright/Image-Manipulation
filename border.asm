#name:		Thomas Wright
#studentID:	260769898

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 1    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 
error:	.asciiz "The file is not acceptable!\n"
space: .asciiz " "
array:	.space 2048

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord
	
	li $v0, 4	#print
	la $a0, newbuff
	syscall	

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
		
makearray:	la $t0, buffer	# next this turns the buffer into a 24x7 int array
		la $t1, array
		li $t9, 0
ma:		bge $t9, 168, return	# done if weve gone through the entire buffer
		lb $t3, 0($t1)
		blt $t3, 48, cont
		bgt, $t3, 57, cont
		lb $t4, 1($t1)
		beq $t4, 0xa, onedig	# one digit if the section of two includes a space or newline
		beq $t4, 0x20, onedig
		addi $t4, $t4, -38
		sw $t4, 0($t0)		# storing the new 2digit integer
		addi $t0, $t0, 4
		addi $t1, $t1, 2
		addi $t9, $t9, 1
		j ma
		
onedig:		addi $t3, $t3, -48	#  adding the int
		sw $t3, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		addi $t9, $t9, 1
		j ma
cont:		addi $t1, $t1, 1
		j ma
return:		jr $ra


bord:		move $s0, $a0	# s0 is buffer
		move $s1, $a1	# s1 is newbuff
		lw $s2, ($a2)	# s2 is border width
		move $s7, $s1 	# s3 will always point to the start of the buffer
		li $t3, 0	# x axis counter
		li $t4, 0	# y axis counter
		mul $s3, $s2, 2
		addi $s4, $s3, 7	# s4 is height
		addi $s3, $s3, 24	# s3 is width
		sub $s5, $s3, $s2	# s5 is x border inside edge
		sub $s6, $s4, $s2	# s6 is y border upper edge
		j check
		
check:		beq $t3, $s3, newline	# if at the end of the line go to newline
		blt $t3, $s2, border # checks to confirm we are within border boundaries
		bge $t3, $s5, border 
		blt $t4, $s2, border
		bge $t4, $s6, border
regrow:		lw $t0, 0($s0)
		bge $t0, 10, td
		j od
td:		li $t1, 49
		sb $t1, 0($s1)		# loading the 1
		addi $t1, $t0, 38
		sb $t1, 1($s1)		# loading the second digit
		li $t1, 32
		sb $t1, 2($s1)		# loading the space
		j ahead
od:		li $t1, 32
		sb $t1, 0($s1)		# loading the space
		addi $t1, $t0, 48
		sb $t1, 1($s1)		# loading the digit
		li $t1, 32
		sb $t1, 2($s1)		# loading the space
ahead:		addi $s0, $s0, 4	# int array increments by one word (or four bits)
		addi $t3, $t3, 1	# incrementing the x-axis counter
		addi $s1, $s1, 3	# moving s3 three forward
		j check	

border:		li $t1, 49
		sb $t1, 0($s1)		# storing the 1
		addi $t1, $zero, 53
		sb $t1, 1($s1)		# storing the second digit
		li $t1, 32
		sb $t1, 2($s1)		# storing the space
		addi $t3, $t3, 1	# incrementing the x-axis counter
		addi $s1, $s1, 3
		j check

newline:	addi $t1, $zero, 10	# adding a newline
		sb $t1, 0($s1)
		addi $t4, $t4, 1	# incrementing the y-axis counter
		addi $s1, $s1, 1
		li $t3, 0
		beq $t4, $s4, done
		j check
		
done: 	jr $ra

#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.

writefile:	move $s0, $a0	# s0 = output
		la $s1, headerbuff	# s1 = headerbuff
		lw $s2, borderwidth	# s2 is borderwidth
		mul $s3, $s2, 2
		addi $s4, $s3, 7	# s4 is height
		addi $s3, $s3, 24	# s3 is width
		la $s7, newbuff	# s7 = newbuff

		li $v0, 13	# opening the file system call
		li $a1, 1	# 1 flag for write
		li $a2, 0	# mode ignored
		syscall
		blt $v0, $zero, errors
		move $s0, $v0	# saving the file descripor
		
		addi $t0, $zero, 80
		sb $t0, 0($s1)		# storing the P
		addi $t0, $zero, 50
		sb $t0, 1($s1)		# storing the 2
		addi $t0, $zero, 10
		sb $t0, 2($s1)		# storing the \n
		
		li $t9, 10
		move $t1, $s3
		div $t1, $t9		
		mflo $t7		# high digit
		mfhi $t8		# low digit
		addi $t7, $t7, 48
		sb $t7, 3($s1)		# storing the low digit
		addi $t8, $t8, 48
		sb $t8, 4($s1)		# storing the high digit
		addi $t0, $zero, 32
		sb $t0, 5($s1)		# storing the space
		bge $s4, 10, tdh
		move $t2, $s4
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
		addi $s6, $s6, 1
		
		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, headerbuff	# loading address of hardcoded image header
		li $a2, 11	# max chars to read
		syscall
		blt $v0, $zero, errors
		
		j finito
		
tdh:		li $t9, 10
		move $t1, $s4
		div $t1, $t9		
		mflo $t7		# high digit
		mfhi $t8		# low digit
		addi $t7, $t7, 48
		sb $t7, 6($s1)		# storing the high digit
		addi $t8, $t8, 48
		sb $t8, 7($s1)		# storing the low digit
		addi $t0, $zero, 10	
		sb $t0, 8($s1)		# storing the \n
		addi $t0, $zero, 49
		sb $t0, 9($s1)		# storing the 1
		addi $t0, $zero, 53
		sb $t0, 10($s1)		# storing the 5
		addi $t0, $zero, 10
		sb $t0, 11($s1)		# storing the \n
		
		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		move $a1, $s1	# loading address of hardcoded image header
		li $a2, 12	# max chars to read
		syscall
		blt $v0, $zero, errors
		
		j finito

finito:		
		li $v0, 15	# writefile syscall
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
