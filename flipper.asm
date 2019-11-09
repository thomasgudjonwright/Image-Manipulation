#name:	Thomas Wright
#studentID:	260769898

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped.pgm"	#used as output
axis: .word 0 # 0 = flip around x-axis....1=flip around y-axis
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 

header: .asciiz "P2\n24 7\n15\n"	# hardcoded header
error:	.asciiz "The file is not acceptable!\n"
space: .asciiz " "
terminator: .asciiz "\0"
nl: .asciiz "\n"
	.text
	.globl main

main:
    la $a0,input	#readfile takes $a0 as input
    jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        #either 0 or 1, specifying x or y axis flip accordingly
	jal flip

	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1,newbuff		#$a1 takes location of what data we wish to write.
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
		la $a1, buffer	# loading address of input buffer
		li $a2, 2048	# max chars to read
		syscall
		move $s0, $v0	# saving the file descripor
		#blt $v0, $zero, errors
		
		li $v0, 16	# close file syscall
		move $a0, $s0
		syscall
		
		jr $ra

flip:	move $s0, $a0
	move $s1, $a1
	lb $t2, ($a2)
	li $t3, 0
	beq $t2, 0, xaxis 	# flip around x axis
	beq $t2, 1, yaxis	# lip around y axis
	
xaxis:	addi $s1, $s1, 426	#start at first val of last line
xa:	lb $t0, 0($s0)
	beq $t0,10, nextline	# go to newline
	sb $t0, 0($s1)		# store the newline
	addi $s1, $s1, 1
	addi $t3, $t3, 1
	addi $s0, $s0, 1
	bge $t3, 497, done	#if we go through all, done
	j xa
nextline:	sb $t0, 0($s1)
		addi $s0, $s0, 1
		addi $s1, $s1, -141	# moving back to next spot on old line
		addi $t3, $t3, 1
		bge $t3, 497, done
		j xa
		
yaxis:	addi $s1, $s1, 69	# moving to end of current line
ya:	lb $t0, 0($s0)
	beq $t0,10, nextliney
	sb $t0, 0($s1)
	addi $s1, $s1, -1
	addi $t3, $t3, 1
	addi $s0, $s0, 1
	bge $t3, 497, done
	j ya
nextliney:	addi, $s1, $s1, 71
		sb $t0, 0($s1)
		addi $s1, $s1, 70
		addi, $s0, $s0, 1
		addi $t3, $t3, 1
		bge $t3, 497, done
		j ya
		
done:	jr $ra
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!

writefile:	la $a3, ($a1)
		li $v0, 13	# opening the file system call
		li $a1, 1	# 1 flag for write
		li $a2, 0	# mode ignored
		syscall
		blt $v0, $zero, errors
		move $s0, $v0	# saving the file descripor
		
		li $v0, 15	# writefile syscall
		la $a0, ($s0)	# loading file descriptor into arg0
		la $a1, header	# loading address of hardcoded image header
		li $a2, 11	# max chars to read
		syscall
		blt $v0, $zero, errors
		
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
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

errors:		li $v0, 4	#print
		la $a0, error
		syscall	
		nop
