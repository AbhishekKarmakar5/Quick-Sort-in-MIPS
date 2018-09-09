.data
	nums:	.word	0:100
	size:	.word	20
.text
.globl main
main:
	#addi $a0, $zero, 0	#place the first location of nums into $a0
	#addi $a1, $zero, 19	#place the last location of nums into $a1
	
		li $v0,5
		syscall
		move $a1,$v0		
	   #la $a0,nums			#$a0,a
		li $a0,0			#$a1,l
		addi $a1,$a1,-1		#size=n-1
		addi $s0,$a2,1		#$s0=n
		sw $v0,size
		
		li $t0,0			#i=0
		addi $t2,$v0,0		#n.... i<n
		la $t3,nums		
		loop:
			beq $t0,$t2,end
			li $v0,5
			syscall
			sw $v0,0($t3)  #the vlalue gerts stored in the array
			addi $t3,$t3,4	#a++
			addi $t0,$t0,1	#i++
			j loop
		end:

	
	jal quicks		#call main quicksort routine
	j print			#print the inplace sorted values
	
quicks:	
	bge $a0, $a1, q_end	#if low is already bigger or equal than high, then stop
	
	addi $sp, $sp, -16	#store the initial values of routine call
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	
	jal part		#find the divider (partition) from the two given arguments
	move $s0, $v0		#place returned value into $s0
	sw $s0, 12($sp)		#store the new partition location	
	
				#prepare to make first recursive call (low, partition -1)
	addi $s0, $s0, -1	#partition - 1
	lw $a0, 4($sp)		#load the saved low location into low argument
	move $a1, $s0		#place (partition - 1) into high argument
	jal quicks		#recursive call with new (low, partition -1)
	
				#prepare to make second recursive call (partition + 1, high)
	lw $s0, 12($sp)		#load the intitial partition location
	addi $s0, $s0, 1		#partition + 1
	move $a0, $s0		#place (partition + 1) into low argument
	lw $a1, 8($sp)		#load saved high location into high argument
	jal quicks		#recursive call with new (partition + 1, high)
	
	lw $ra, 0($sp)		#load the calling return address from stack
	addi $sp, $sp, 16	#pop stock
q_end:	
	jr $ra			#return to caller
			
part:
	addi $sp, $sp, -24	#save state including return
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	move $s0, $a0		#place the low value into $s0
	move $s1, $a1		#place the high value into $s1
	
	la $t0, nums		#get the array start address into $t0
	sll $t1, $s1, 2		#multiply the $a1 (high value) by 4 to get the correct offset
	add $t2, $t0, $t1
	lw $s2, 0($t2)		#put the pivot (array[high]) into s2
	 
   	li $v0, 1
   	move $a0, $s2
    	syscall
	la $a0, space		#print space between numbers
	li $v0, 4
	syscall
	
	addi $s3, $s0, -1	#set $s3 = to i (low - 1)
	move $s4, $s0		#j = low
	
	
forloop:			#start of loop that steps through the nums array from low to high
	sll $t1, $s4, 2		#use temp register to get the byte offset at location j
	add $t2, $t0, $t1
	lw $t3, 0($t2)		#get the value of nums[j]
	
	bge $t3, $s2, elsefor	#if value at nums[j] >= pivot, then nums[j] already in the right location
	
				#prepare to swap the values at nums[j] and the partition
				#to put smaller value before the pivot
	addi $s3, $s3, 1	#nums[j] < pivot, increment pointer to partition to make room for swapped value
	move $a0, $s3		#load locations to swap
	move $a1, $s4
	jal swap		#swap values
	
elsefor:	
	addi $s4, $s4, 1	 	#increment counter j
	blt $s4, $s1, forloop	#check next location of nums[j]
				
				#prepare to swap pivot with the location dividing low/high values
	addi $s3, $s3, 1		#increment counter i
	move $a0, $s3		#load locations to swap
	move $a1, $s1
	jal swap		#swap the low and high location

	move $v0, $s3		#put the new partition location into return register
	lw $ra, 0($sp)		#load the previous state
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24	#pop stack
	jr $ra			#return to caller

swap:
	.text
	sll $a0, $a0, 2		#multiply indexes by 4 to get proper byte location
	sll $a1, $a1, 2
	la $t0, nums		#set $t0 to the address of nums

	add $t1, $t0, $a0	#get the value inside nums array at location $a0
	add $t2, $t0, $a1	#get the value inside nums array at location $a1

	lw $t3, 0($t1)		#save these values into temp locations $t3 and $t4
	lw $t4, 0($t2)

	sw $t4, 0($t1)		#swap values
	sw $t3, 0($t2)
	
	jr $ra			#return to caller

	.data
space:	.asciiz " "
newline: .asciiz "\n"
head:	.asciiz "The sorted numbers are:\n"
	.text
print:	la $t0, nums		#load address of number array
	lw $t1, size		#load integer of size of the array

	la $a0, head		#print header
	li $v0, 4
	syscall

output:	lw $a0, 0($t0)		#print value of nums array
	li $v0, 1
	syscall

	la $a0, space		#print space between numbers
	li $v0, 4
	syscall

	addi $t0, $t0, 4		#increment pointer inside nums array
	addi $t1, $t1, -1		#decrement loop counter

	bgtz $t1, output	#return back to start until loop counter is less than 0

exit:	li $v0, 10		#syscall to exit
	syscall
