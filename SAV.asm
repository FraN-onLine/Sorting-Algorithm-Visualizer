.data
ints: .space 24
prompt: .asciiz "Enter a number: "
originalarray: .asciiz "Original Array is: "
mergetemp1: .space 12 #left half
mergetemp2: .space 12 #right half
mergetemp3: .space 8
mergetemp4: .space 8
res: .asciiz "Sorted: "
com_space: .asciiz ", "
space: .asciiz " "
menu: .asciiz "\nChoose Sorting Algorithm:\n1. Bubble Sort\n2. Insertion Sort 3,Merge Sort\nEnter Choice: "

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
    
    #++++++++++++++++++++++++++CHANGES
    #Print menu for algorithm selection
    li $v0, 4
    la $a0, menu
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0  # Store choice in $s0
    
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
#++++++++++++++++++Changes
 # Branch to appropriate sorting algorithm based on choice
    li $t0, 1
    beq $s0, $t0, bubble_sort_start  # If choice == 1, go to bubble sort
    beq $s0, 2, insertion_sort_start # 2. ins
    j merge_sort_start # else merge muna.....

bubble_sort_start:
    li $t0, 0 #counter
    la $t1, ints #integers
    li $t3, 0 # index being compared
    j bubblesort
 
insertion_sort_start:
	li $t0, 1 #start from 2nd element
	la $t1, ints
	j insertionsort
	
merge_sort_start:
	la $t1 ints
    j mergesort
    
    #====================================================================#
    #================Bubble Sort=========================================#
bubblesort:
	 #need base case to check if soeted here-
	 issorted:
   		 la $t1, ints         # start of array
    		li $t0, 0            # index counter

	checkloop:
    		lw $t6, 0($t1)       # load current element
  		  lw $t7, 4($t1)       # load next element

    		bgt $t6, $t7, outoforder  # if out of order, start sorting

 		addi $t1, $t1, 4     # move to next pair
   		addi $t0, $t0, 1
    		blt $t0, 5, checkloop 

    		# If reached here, it's sorted already
    		 li $t0, 0 #counter
   		 la $t1, ints #integers
    		li $v0, 4
    		la $a0, res
    		syscall
    		j exit
    	outoforder:
    		li $t5, 0 #counter 2
		 la $t1, ints #integers from the start once more
	
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

#====================================================================#
#================Insertion Sort=======================================#
insertionsort:
    beq $t0, 6, insertion_done  # If we've processed all elements, we're done
    
    la $t1, ints               # Reset array pointer
    move $t2, $t0              # Copy current position to $t2
    mul $t3, $t2, 4           # Calculate offset for current element
    add $t1, $t1, $t3         # Point to current element
    lw $t4, 0($t1)            # Load current element value (key)
    
    # Print initial state before insertion
    la $t7, ints              # Start of array
    li $t8, 0                 # Counter for printing
    
print_array_state:
    beq $t8, 6, print_newline    # If printed all elements, print newline
    
    lw $t3, 0($t7)           # Load current number
    
    # Check if we're at the partition point
    beq $t8, $t0, print_partition
    
    # Print regular number
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    j continue_printing

print_partition:
    # Print partition symbol
    li $v0, 11
    li $a0, '|'
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Print key in brackets
    li $v0, 11
    li $a0, '['
    syscall
    
    li $v0, 1
    move $a0, $t4    # Print the key
    syscall
    
    li $v0, 11
    li $a0, ']'
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Continue printing remaining numbers
    addi $t7, $t7, 4
    addi $t8, $t8, 1
    j print_remaining

print_remaining:
    beq $t8, 6, print_newline
    
    lw $t3, 0($t7)
    
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t7, $t7, 4
    addi $t8, $t8, 1
    j print_remaining

continue_printing:
    addi $t7, $t7, 4         # Move to next element
    addi $t8, $t8, 1         # Increment counter
    j print_array_state

print_newline:
    li $v0, 11
    li $a0, '\n'
    syscall

insertion_inner:
    beq $t2, 0, insertion_inner_done  # If we're at start of array, inner loop done
    
    addi $t5, $t1, -4         # Point to previous element
    lw $t6, 0($t5)            # Load previous element
    
    ble $t6, $t4, insertion_inner_done  # If previous <= current, inner loop done
    
    # Perform the swap
    sw $t6, 0($t1)            # Move larger element right
    sw $t4, 0($t5)            # Place current element in gap
    
    addi $t1, $t1, -4         # Move left one position
    addi $t2, $t2, -1         # Decrement position counter
    j insertion_inner

insertion_inner_done:
    addi $t0, $t0, 1          # Move to next element
    j insertionsort

insertion_done:
    # Print final sorted array
    la $t7, ints
    li $t8, 0

print_final_state:
    beq $t8, 6, finish_sort
    
    lw $t3, 0($t7)
    
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t7, $t7, 4
    addi $t8, $t8, 1
    j print_final_state

finish_sort:
    li $v0, 11
    li $a0, '\n'
    syscall
    
    li $v0, 4
    la $a0, res
    syscall
    j exit
    
 # ==================== Merge Sort ========================= #
mergesort:
    la $t2, mergetemp1 # xxx | yyy
    la $t3, mergetemp2 # xxx | yyy
    la $t4, mergetemp3 # w | xx | yyy
    la $t5, mergetemp4	 # w | xx | yy | z
    li $t0, 0 #counter
 
 split1:
 
 	cutfirsthalf:
  	 lw $t6, 0($t1) #get from ints
   	 sw $t6, 0($t2) #store to temp1
   	addi $t1, $t1, 4
    	addi $t2, $t2, 4
    	addi $t0, $t0, 1
    	blt $t0, 3, cutfirsthalf

    	la $t1, ints
    	addi $t1, $t1, 12  # Move to index 3
    	li $t0, 0

cutsecondhalf:
  	 lw $t6, 0($t1) #get from ints
   	 sw $t6, 0($t2) #store to temp1
   	addi $t1, $t1, 4
    	addi $t2, $t2, 4
    	addi $t0, $t0, 1
    	blt $t0, 3, cutsecondhalf
    	
#print cut
    la $t2, mergetemp1 # xxx | yyy
    la $t3, mergetemp2 # xxx | yyy
    lw $t6, 0($t2) #get from temp1
   sw $t6, $s1 #store to save 1
    lw $t6, 0($t3) #get from temp2
   sw $t6, $s2 #store to save2 


   #break muna

# ================= End of Merge Sort ====================== #

    
#++++++++++++++++++++Changes
exit:
	li $t0, 0 #reset counter
	la $t1, ints #reset arr pointer

print_final:
    lw	$t2, 0($t1) #load
    addi $t0, $t0, 1 #i++
    add $t1, $t1, 4 #shift 4 for each int
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    beq $t0, 6, islastdigit2
    
    li $v0, 4
    la $a0, com_space
    syscall
    
    j print_final
islastdigit2:
    li $v0, 4
    la $a0, space
    syscall

    blt $t0, 6, exit
