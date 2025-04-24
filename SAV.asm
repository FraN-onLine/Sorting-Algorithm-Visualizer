.data
ints: .space 24
prompt: .asciiz "Enter a number: "
originalarray: .asciiz "Original Array is: "
res: .asciiz "result: "
com_space: .asciiz ", "
space: .asciiz " "

.text
.globl main

main:
    li $t0, 0 #counter
    la $t1, ints #integers

loop:
    li $v0, 4
    la $a0, prompt
    syscall
    
    li $v0, 5
    syscall
    move $t2, $v0  # Store input in $t2
    
    sw	$t2, 0($t1) #store
    addi $t0, $t0, 1 #i++
    add $t1, $t1, 4 #shift 4 for each int
    blt $t0, 6, loop
    
    li $t0, 0 #counter
    la $t1, ints #integers
    
     li $v0, 4
    la $a0, originalarray
    syscall
    
printarray:
    lbu	$t2, 0($t1) #load
    addi $t0, $t0, 1 #i++
    add $t1, $t1, 4 #shift 4 for each int
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    beq $t0, 6, islastdigit
    
    li $v0, 4
    la $a0, com_space
    syscall
islastdigit:
    li $v0, 4
    la $a0, space
    syscall

    blt $t0, 6, printarray
    
    li $v0, 11
    	li $a0, '\n'
   	 syscall

    li $t0, 0 #counter
    la $t1, ints #integers
    li $t3, 0 # index being compared
    
    
bubblesort:
	li $t5, 0 #counter 2
	 la $t1, ints #integers from the start once more
	 
	 #need base case to check if soeted here-
	
bubbleloopmain: #will print out all til we reach the index of comparison
   
   beq $t5, $t3, bubbleloop1
    lw $t2, 0($t1) #load on t2
    addi $t5, $t5, 1 #counter 2++
    add $t1, $t1, 4 #shift 4 for each int
    
    li $v0, 1
    move $a0, $t2
    syscall
    
     li $v0, 4
    la $a0, space
    syscall
    
    blt $t5, 6, bubbleloopmain
    addi $t3, $t3, 1 #index being compared++
    li $v0, 11
    li $a0, '\n'
    syscall
    j bubblesort
    
    bubbleloop1: #this occurs when we reach the indices to be compared
    	lw	$t2, 0($t1) #load no 1 to compare
        addi $t0, $t0, 1 #i++
        add $t1, $t1, 4 #shift 4 for each int
        lw	$t4, 0($t1) #load number 2 to compare
    
        li $v0, 11
        li $a0, '['
        syscall

        li $v0, 1
        move $a0, $t2
    	syscall

  	  li $v0, 11
    	li $a0, ','
    	syscall

   	 li $v0, 11
    	li $a0, ' '
  	  syscall

    	li $v0, 1
    	move $a0, $t4
    	syscall

    	li $v0, 11
    	li $a0, ']'
   	 syscall
   	 
   	  li $v0, 4
         la $a0, space
        syscall
    	
    	bgt	$t2, $t4, swap
    	j skipswap
    	
    	swap:
    		sw $t2 0($t1)
    		sw $t4 -4($t1)
    	
    	skipswap:
    	add $t1, $t1, 4 #shift 4 for each int
	
	addi $t5, $t5 2 #counter 2 += 2
	blt  $t5, 6, bubbleloopmain
	li $t3, 0 #index being compared++
	 li $v0, 11
        li $a0, '\n'
        syscall
   	 j bubblesort
    	
