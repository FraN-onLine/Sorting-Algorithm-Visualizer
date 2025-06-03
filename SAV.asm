.data
ints: .space 24 #this is for the 6 numbers 4*6  = 24
mergetemp1: .space 12 #left half
mergetemp2: .space 12 #right half
mergetemp3: .space 8
mergetemp4: .space 8
initMessage: .asciiz "-----Sorting Algorithm Visualizer-----\nPlease Enter 6 Digits to Start Visualization\n"
prompt: .asciiz "Enter a number: "
originalarray: .asciiz "Original Array is: "
res: .asciiz "Sorted: "
com_space: .asciiz ", "
space: .asciiz " "
menu: .asciiz "\nChoose Sorting Algorithm:\n1. Bubble Sort\n2. Insertion Sort \n3. Merge Sort\n4. Quicksort\n5. Heap Sort\n6. Random Sort \n7. Radix Sort\nEnter Choice: "
divide: .asciiz "divide: "
sort: .asciiz "sort: "
merge: .asciiz "merge: "
pivot: .asciiz "Pivot: "
pointers: .asciiz "ptr1 = '>' ptr2 = '<'\n"
ptr1: .asciiz "> "
ptr2: .asciiz "< "
comparing: .asciiz "Comparing Ptr 1 and Pivot: "
swapmsg: .asciiz "Swapping Ptr1 and Ptr2\n"
moveptr1: .asciiz "Moving Ptr1..\n"
moveptr2: .asciiz "Moving Ptr2..\n"
ptr2is: .asciiz "Pointer 2 is now: "
startit: .asciiz "\n-------Start of New Iteration-------\n"
#heap
heap_building: .asciiz "\nBuilding max heap: "
heap_extract: .asciiz "\nExtracting max: "
swap_root: .asciiz "Swap root with last leaf: "
heapify_msg: .asciiz "Heapifying: "
#random
steps_msg: .asciiz "\nNumber of steps taken to sort: "
#radix
radix_msg: .asciiz "\nProcessing digit position: "
bucket_msg: .asciiz "\nCurrent buckets:\n"
bucket0: .asciiz "Bucket 0: "
bucket1: .asciiz "Bucket 1: "
bucket2: .asciiz "Bucket 2: "
bucket3: .asciiz "Bucket 3: "
bucket4: .asciiz "Bucket 4: "
bucket5: .asciiz "Bucket 5: "
bucket6: .asciiz "Bucket 6: "
bucket7: .asciiz "Bucket 7: "
bucket8: .asciiz "Bucket 8: "
bucket9: .asciiz "Bucket 9: "
after_pass: .asciiz "\nAfter this pass: "
.align 2
buckets: .space 400  # Space for 10 buckets (10 * 10 words)
count: .space 40     # Count array (10 words)
nonePicked: .asciiz "No Sorting Algorithm Picked, Terminating Program....."
invalidmsg: .asciiz "Invalid input! Please enter an integer number only.\n\n"
inputbuffer: .space 32

.text
.globl main

main:

    li $t0, 0 #counter
    la $t1, ints #integers
    
    li $v0, 4
    la $a0, initMessage
    syscall

loop:
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 8 #read as string muna for validation
    la $a0, inputbuffer
    li $a1, 32
    syscall

    # Validate input: check if it's a valid integer string
    la $a0, inputbuffer
    jal isValidInt #use a function and pass along input string
    beq $v0, $zero, invalid   # if not valid, prompt again

    # Convert string to integer
    la $a0, inputbuffer
    jal str2int #jumps and links to the conversion function
    move $t2, $v0 #$v0 now has the integer

    sw	$t2, 0($t1) #store
    addi $t0, $t0, 1 #i++
    add $t1, $t1, 4 #shift 4 for each int
    blt $t0, 6, loop

    j afterloop

invalid:
    li $v0, 4
    la $a0, invalidmsg
    syscall
    j loop

afterloop:
    
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

    lw	$t2, 0($t1) #load
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

 # Branch to appropriate sorting algorithm based on choice
    beq $s0, 1, bubble_sort_start  # If choice == 1, go to bubble sort
    beq $s0, 2, insertion_sort_start 
    beq $s0, 3, merge_sort_start 
    beq $s0, 4, quick_sort_start 
    beq $s0, 5, heap_sort_start
    beq $s0, 6, random_sort_start
    beq $s0, 7, radix_sort_start 
    
    li $v0, 4
    la $a0, nonePicked
    syscall
    
    j exit

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
	la $t1, ints
    j mergesort
    
quick_sort_start:
    	la $t1, ints
    j quicksort
    
heap_sort_start:
    li $t0, 0        
    la $t1, ints     
    j heapsort
    
random_sort_start:
    li $t0, 0        # Initialize counter
    la $t1, ints     # Load array base
    j randomsort

radix_sort_start:
    # Initialize
    la $t1, ints     # Load address of input array
    li $s0, 1        # Initialize digit position to 1 (ones place)
    li $s1, 0        # Will store number of digits in largest number
    
    # Find maximum number to determine number of digits
    li $t0, 0        # Counter
    li $t2, 0        # Max number
    j find_max
    
    #====================================================================#
    #================Bubble Sort=========================================#
    
bubblesort:
	 #need base case to check if soeted here-
	 issorted:
   		 la $t1, ints # start of array
    		li $t0, 0  # index counter
    		li $t5, 0 #counter 2 when printing non compared indices

	bne $t3, 0, bubbleloopmain
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
	li $t3, 0 #index being compared goes back to first if and only if were comparing the last 2 elements
	 li $v0, 11
        li $a0, '\n'
        syscall
   	 j bubblesort

#====================================================================#
#================Insertion Sort=======================================#
insertionsort:
    # This is our main insertion sort function
    # We start from index 1 (second element) since a single element is already sorted
    beq $t0, 6, insertion_done  # If we've processed all elements, we're done
    
    la $t1, ints               # Reset array pointer. Get base address of array
    move $t2, $t0              # Copy current position to $t2. Copy current position to compare
    mul $t3, $t2, 4           # Calculate offset for current element (each int is 4 bytes)
    add $t1, $t1, $t3         # Point to current element
    lw $t4, 0($t1)            # Load current element value (key), value we're trying to insert
    
    # Print initial state before insertion
    la $t7, ints              # Start of array
    li $t8, 0                 # Counter for printing
    
print_array_state:
    # This procedure prints the current state of the array during insertion sort
    # Shows the sorted portion, partition point, and unsorted portion
    beq $t8, 6, print_newline    # If printed all elements, print newline
    
    lw $t3, 0($t7)           # Load current number from array
    
    # Check if we're at the partition point, if current pos is at the partition point between
    # sorted and unsorted 
    beq $t8, $t0, print_partition
    
    # Print regular number (numbers in sorted portion)
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    j continue_printing

print_partition:
# This section prints the partition point with visual indicators
    # Print partition symbol
    li $v0, 11
    li $a0, '|'           # Print vertical bar to mark partition
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Print key value in brackets to highlight current element being inserted
    li $v0, 11
    li $a0, '['
    syscall
    
    li $v0, 1
    move $a0, $t4    # Print the key value here
    syscall
    
    li $v0, 11
    li $a0, ']'
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Continue printing remaining numbers
    addi $t7, $t7, 4 # Move to next element
    addi $t8, $t8, 1 # Increment counter
    j print_remaining

print_remaining:
# Prints the remaining unsorted portion after the partition
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
    # Helper procedure to continue printing array elements
    addi $t7, $t7, 4         # Move to next element
    addi $t8, $t8, 1         # Increment counter
    j print_array_state

print_newline:
    li $v0, 11
    li $a0, '\n'
    syscall

insertion_inner:
# This is our inner loop that shifts elements to make room for insertion
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
   
    j exit
    
 # ==================== Merge Sort ========================= #
mergesort:
    la $t2, mergetemp1 # xxx | yyy
    la $t3, mergetemp2 # xxx | yyy
    la $t4, mergetemp3 # w | xx | yyy
    la $t5, mergetemp4	 # w | xx | yy | z
    li $t0, 0 #counter
    
    li $v0, 4
    la $a0, divide
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
 
 split1:
     la $t2, mergetemp1 # xxx | yyy
 
 cutfirsthalf:
  	 lw $t6, 0($t1) #get from ints
   	sw $t6, 0($t2) #store to mwegwtemp1
   	addi $t1, $t1, 4
    	addi $t2, $t2, 4
    	addi $t0, $t0, 1
    	blt $t0, 3, cutfirsthalf

    	la $t1, ints
    	addi $t1, $t1, 12  # Move to index 3
    	li $t0, 0

cutsecondhalf:
  	 lw $t6, 0($t1) #get from ints
   	 sw $t6, 0($t3) #store to mergetemp2
   	addi $t1, $t1, 4
    	addi $t3, $t3, 4
    	addi $t0, $t0, 1
    	blt $t0, 3, cutsecondhalf
    	
#print cut
# Print first 3 (mergetemp1)
    la $t2, mergetemp1
    li $t0, 0
    
printcut1:
    lw $a0, 0($t2)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, space
    syscall

    addi $t2, $t2, 4
    addi $t0, $t0, 1
    blt $t0, 3, printcut1
	
    li $v0, 11
    li $a0, '|'
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall

    li $t0, 0

printcut2:
    lw $a0, 0($t2)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, space
    syscall

    addi $t2, $t2, 4
    addi $t0, $t0, 1
    blt $t0, 3, printcut2
    
    li $v0, 11
    li $a0, '\n'
    syscall

#we cut again from here
    la $t2, mergetemp1 # xxx | yyy
    la $t3, mergetemp2 # xxx | yyy
    
    # these isolate the corner elements, cut off entirely and leaves the other two of each half
    lw $s1, 0($t2) #split again
    lw $s2, 8($t3) #split rightmost

#prints and cuts for the second time
    move $a0, $s1
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
     li $v0, 11
    li $a0, '|'
    syscall
    
    li $v0, 11
    li $a0, ' '
    syscall
    
    lw $t6, 4($t2) #get from mergetemp1
    sw $t6, 0($t4) #store to mergetemp3
    move $a0, $t6
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
    lw $t6, 8($t2) #get from mergetemp1
    sw $t6, 4($t4) #store to mergetemp3
    move $a0, $t6
    li $v0, 1
    syscall
   	
    li $v0, 11
    li $a0, '|'
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
  #second halffff
    
    lw $t6, 0($t3) #get from mergetemp1
    sw $t6, 0($t5) #store to mergetemp3
    move $a0, $t6
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
    lw $t6, 4($t3) #get from mergetemp1
    sw $t6, 4($t5) #store to mergetemp3
    move $a0, $t6
    li $v0, 1
    syscall
   	
    li $v0, 11
    li $a0, ' '
    syscall
    
    li $v0, 11
    li $a0, '|'
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
    move $a0, $s2
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, '\n'
    syscall
    
 #---------SORT--------------
    li $v0, 4
    la $a0, sort
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    
 #sort mergetemp3 and 4
    la $t4, mergetemp3 
    la $t5, mergetemp4	 
    
    # a > b (swap)
    lw $t6, 0($t4)
    lw $t7, 4($t4)
    blt $t6, $t7, skipswap1
    
    sw $t6, 4($t4)
    sw $t7, 0($t4)
 
skipswap1:
    # a > b (swap)
    lw $t6, 0($t5)
    lw $t7, 4($t5)
    blt $t6, $t7, skipswap2
    
    sw $t6, 4($t5)
    sw $t7, 0($t5)

skipswap2: #print sorted, starting for isolated value1 -> temp 3 -> temp 4 -> isolated value 2
     
     move $a0, $s1
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
     li $v0, 11
    li $a0, '|'
    syscall
    
    li $v0, 11
    li $a0, ' '
    syscall
    
    lw $t6, 0($t4) #get from mergetemp3
    move $a0, $t6
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
    lw $t6, 4($t4) #get from mergetemp3
    move $a0, $t6
    li $v0, 1
    syscall
   	
    li $v0, 11
    li $a0, ' '
    syscall
    
    li $v0, 11
    li $a0, '|'
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
  #second halffff
    
    lw $t6, 0($t5) #get from mergetemp4
    move $a0, $t6
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
    lw $t6, 4($t5) #get from mergetemp4
    move $a0, $t6
    li $v0, 1
    syscall
   	
    li $v0, 11
    li $a0, ' '
    syscall
    
    li $v0, 11
    li $a0, '|'
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall
    
    move $a0, $s2
    li $v0, 1
    syscall
    
     li $v0, 11
    li $a0, '\n'
    syscall
    
  #---------Merge--------------
  
    li $v0, 4
    la $a0, merge
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
  
  #Merge Left
    lw $t6, 0($t4) #min of temp 3
    move $t7, $s1 #isolated int 
    blt $t6, $t7, storeMergedMin1
    
#else the isolated is the mnimum, move the merged on the index 2 and 3 
    sw $t7, 0($t2)
    sw $t6, 4($t2)
    lw $t6, 4($t4) #max of temp 3
     sw $t6, 8($t2)
    j mergeRight
    
 storeMergedMin1:
    sw $t6, 0($t2)
    lw $t6, 4($t4) #max of temp 3
    blt $t6, $t7, storeMergedMax1
    
 #else the isolated is the lesser of the two, store the max at the last index
     sw $t7, 4($t2)
     sw $t6, 8($t2)
    j mergeRight
    
 storeMergedMax1:
 #the isolated is the maximum
     sw $t7, 8($t2)
     sw $t6, 4($t2)
  
 mergeRight:
  #Merge Right
    lw $t6, 0($t5) #min of temp 4
    move $t7, $s2 #isolated int 
    blt $t6, $t7, storeMergedMin2
    
#else the isolated is the mnimum, move the merged on the index 2 and 3 
    sw $t7, 0($t3)
    sw $t6, 4($t3)
    lw $t6, 4($t5) #max of temp 3
     sw $t6, 8($t3)
      li $t0, 0
    j mergePrint1
    
 storeMergedMin2:
    sw $t6, 0($t3)
    lw $t6, 4($t5) #max of temp 3
    blt $t6, $t7, storeMergedMax2
    
 #else the isolated is the lesser of the two, store the max at the last index
     sw $t7, 4($t3)
     sw $t6, 8($t3)
      li $t0, 0
    j mergePrint1
    
 storeMergedMax2:
 #the isolated is the maximum
     sw $t7, 8($t3)
     sw $t6, 4($t3)
     
  li $t0, 0
     
 mergePrint1:
    lw $a0, 0($t2)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, space
    syscall

    addi $t2, $t2, 4
    addi $t0, $t0, 1
    blt $t0, 3, mergePrint1
	

    li $v0, 11
    li $a0, '|'
    syscall
    
     li $v0, 11
    li $a0, ' '
    syscall

    li $t0, 0

mergePrint2:
    lw $a0, 0($t2)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, space
    syscall

    addi $t2, $t2, 4
    addi $t0, $t0, 1
    blt $t0, 3, mergePrint2
    
    li $v0, 11
    li $a0, '\n'
    syscall
  
#-----Merge Again!!!!!!!!!!!!!!!!!!!!------

    la $t1, ints  #final
    la $t2, mergetemp1 # xxx
    la $t3, mergetemp2 # yyy
    li $t4, 0 #counter of x's merged into final
    li $t5, 0 #counter of y's merged into final
     li $t8, 0 # merged counter (total 6)
     
finalmergeloop:
    beq $t8, 6, donefinalmerge   # If 6 elements merged, done

    # Check if left side is exhausted
    li $t9, 3
    bge $t4, $t9, useRightOnly

    # Check if right side is exhausted
    bge $t5, $t9, useLeftOnly

    # Load current elements
    mul $t9, $t4, 4     # t9 = offset for left
    add $t9, $t2, $t9
    lw $t6, 0($t9)      # t6 = current left

    mul $t9, $t5, 4     # t9 = offset for right
    add $t9, $t3, $t9
    lw $t7, 0($t9)      # t7 = current right

    # Compare and pick smaller
    blt $t6, $t7, pickLeft

pickRight:
    sw $t7, 0($t1)
    addi $t5, $t5, 1     # right++
    addi $t1, $t1, 4     # output++
    addi $t8, $t8, 1     # merged++
    j finalmergeloop

pickLeft:
    sw $t6, 0($t1)
    addi $t4, $t4, 1     # left++
    addi $t1, $t1, 4     # output++
    addi $t8, $t8, 1     # merged++
    j finalmergeloop

useRightOnly:
    mul $t9, $t5, 4
    add $t9, $t3, $t9
    lw $t7, 0($t9)
    sw $t7, 0($t1)
    addi $t5, $t5, 1
    addi $t1, $t1, 4
    addi $t8, $t8, 1
    j finalmergeloop

useLeftOnly:
    mul $t9, $t4, 4
    add $t9, $t2, $t9
    lw $t6, 0($t9)
    sw $t6, 0($t1)
    addi $t4, $t4, 1
    addi $t1, $t1, 4
    addi $t8, $t8, 1
    j finalmergeloop

donefinalmerge:
        li $t0, 0
    la $t1, ints
printfinal:
#after merge
    lw $a0, 0($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, space
    syscall

    addi $t1, $t1, 4
    addi $t0, $t0, 1
    blt $t0, 6, printfinal

    li $v0, 11
    li $a0, '\n'
    syscall
    j exit
    
#-----------------Quicksort-------------------
quicksort:
#step1, get the pivot:
   lw $s0, 20($t1) #last element of ints, we'll be making good use of offsets for quicksort instead compared to the other previous sorts that makes use of temp memory or using an offset 0 and incrementing 
    li $v0, 4
    la $a0, pivot
    syscall

    li $v0, 1
   move $a0, $s0
   syscall

    li $v0, 11
    la $a0, '\n'
    syscall
    
    li $t0, 0 #this serves as our counter
    la $t2, ints #ptr1
    la $t3 ints #ptr2
    li $t4, -1 #locptr1
    li $t5, -1 #locptr2
    
    li $v0, 4
    la $a0, pointers
    syscall
    
    li $v0, 4
    la $a0, startit
    syscall
    
 #i used zero based indices here btw uwah uwah
 
 # TAKE NOTE
# s0 - is the VALUE of the first pivot, afterwards it will be overriden by it's FIXED location
# upper bound and lower bound in this iteration will be indices 0 and 5

quickloopstart:
    la $t1, ints
    addiu $t4, $t4, 1 #moveptr1
    li $t7, 0 #innercounter
    li $v0, 4
    la $a0, moveptr1
    syscall
    
printloopqck:
    lw $t6, 0($t1)  #get 
    bne $t4, $t7, dontPrintPtr1 #how specific does my naming have to be?
    li $v0, 4
    la $a0, ptr1
    syscall
 
dontPrintPtr1:
    li $v0, 1
    move $a0, $t6
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    bne $t5, $t7, dontPrintPtr2 #yesnt
    li $v0, 4
    la $a0, ptr2
    syscall
    
dontPrintPtr2:
    addiu $t7, $t7, 1
    add $t1, $t1, 4
    beq $t7, 6, compare
    j printloopqck
    
compare:
    li $v0, 11
    la $a0, '\n'
    syscall
    
    la $t1, ints #this is used to reorder base 
    
    li $v0, 4
    la $a0, comparing
    syscall
    
    li $v0, 1
    lw $t7, 0($t2) #get ptr1
    move $a0, $t7
    syscall
    
     li $v0, 4
    la $a0, com_space
    syscall
    
    li $v0, 1
    move $a0, $s0
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    
    ble $t7, $s0, moveptr2func
    j skipcompare
    
moveptr2func:
      addiu $t5 $t5, 1 #moveptr2
      li $v0, 4
      la $a0, moveptr2
     syscall
     
     jal printforquicksort
     
     beqz $t5, dontmove #this just means ptr is now on index 0
     add $t3 $t3, 4
dontmove:
    #next stepcheck if equal or ahead
      li $v0, 4
      la $a0, ptr2is
     syscall
     lw $t7 0($t3) #get ptr2
     
    li $v0, 1
    move $a0, $t7
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    beq $t4, $t5, skipcompare #if they point at the same position, skip else swap
    lw $t8 0($t2) #gets ptr1
    
    li $v0, 4
    la $a0, swapmsg
    syscall
    
    #calculate position of ptr1 and 2
    la $t1, ints
    move $t9, $t4 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t7 0($t1)
    la $t1, ints #this is used to reorder base 
    move $t9, $t5 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t8 0($t1)
    
    jal printforquicksort
    
skipcompare:
    add $t0, $t0, 1
    add $t2 $t2, 4
    li $v0, 11
    la $a0, '\n'
    syscall
    bne $t0, 6, quickloopstart
    
#by this point ORIGINAL PIVOT IS LOCKED IN PLACE
#and is now at the position of pointer 2

move $s0, $t5 #location of locked pointer 2
#we'll start on the left side if it is not sorted

move $s2, $s0 #location of the previous pivot
li $s7, 5
ble  $s0, 1, quicksortRIGHTSIDE 
move $s7, $s0 #this is where it will end, originally by pivot's location

# TAKE NOTE
# s0 - is now the location of the first FIXED pivot, from here we sort it's left first
# s1 - is the value of current pivot
# s2- is the location of previous pivot
# s3- the location of the previous->previous pivot
# s4 - value of the pivot (referring to lr)
# s7 - is where the loop ends

quicksortLEFTSIDE:

jal checksorted #if its sorted, exit

ble  $s0, 1, quicksortRIGHTSIDE #if its the first or second element, immediately do right side
#sort using quicksort 0 to n-1, where n is index of new pivot

    li $v0, 4
    la $a0, startit
    syscall

   la $t1, ints
   move $t0, $s2
   subi $t0, $t0, 1
   mul $t0, $t0, 4
   add $t1, $t1, $t0
   #our pivot is now on $s1
   lw $s1, 0($t1) #last element of ints, we'll be making good use of offsets for quicksort instead compared to the other previous sorts that makes use of temp memory or using an offset 0 and incrementing 
    li $v0, 4
    la $a0, pivot
    syscall

    li $v0, 1
   move $a0, $s1
   syscall

    li $v0, 11
    la $a0, '\n'
    syscall
    
    li $t0, 0 #this serves as our counter
    la $t1, ints
    la $t2, ints #ptr1
    la $t3 ints #ptr2
    li $t4, -1 #locptr1
    li $t5, -1 #locptr2

    #i used zero based indices here btw uwah uwah
quickloopstartl:
    la $t1, ints
    addiu $t4, $t4, 1 #moveptr1
    li $t7, 0 #innercounter
    li $v0, 4
    la $a0, moveptr1
    syscall
    
printloopqckl:
    lw $t6, 0($t1)  #get 
    bne $t4, $t7, dontPrintPtr1l #how specific does my naming have to be?
    li $v0, 4
    la $a0, ptr1
    syscall
 
dontPrintPtr1l:
    li $v0, 1
    move $a0, $t6
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    bne $t5, $t7, dontPrintPtr2l #yesnt
    li $v0, 4
    la $a0, ptr2
    syscall
    
dontPrintPtr2l:
    addiu $t7, $t7, 1
    add $t1, $t1, 4
    beq $t7, 6, comparel
    j printloopqckl
    
comparel:
    li $v0, 11
    la $a0, '\n'
    syscall
    
    la $t1, ints #this is used to reorder base 
    
    li $v0, 4
    la $a0, comparing
    syscall
    
    li $v0, 1
    lw $t7, 0($t2) #get ptr1
    move $a0, $t7
    syscall
    
     li $v0, 4
    la $a0, com_space
    syscall
    
    li $v0, 1
    move $a0, $s1
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    
    ble $t7, $s1, moveptr2funcl
    j skipcomparel
    
moveptr2funcl:
      addiu $t5 $t5, 1 #moveptr2
      li $v0, 4
      la $a0, moveptr2
     syscall
     
     jal printforquicksort
     
     beqz $t5, dontmovel #this just means ptr is now on index 0
     add $t3 $t3, 4
dontmovel:
    #next stepcheck if equal or ahead
      li $v0, 4
      la $a0, ptr2is
     syscall
     lw $t7 0($t3) #get ptr2
     
    li $v0, 1
    move $a0, $t7
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    beq $t4, $t5, skipcomparel #if they point at the same position, skip else swap
    lw $t8 0($t2) #gets ptr1
    
    li $v0, 4
    la $a0, swapmsg
    syscall
    
    #calculate position of ptr1 and 2
    la $t1, ints
    move $t9, $t4 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t7 0($t1)
    la $t1, ints #this is used to reorder base 
    move $t9, $t5 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t8 0($t1)
    
    jal printforquicksort
    
skipcomparel:
    add $t0, $t0, 1
    add $t2 $t2, 4
    li $v0, 11
    la $a0, '\n'
    syscall
    bne $t0, $s7, quickloopstartl

move $s3, $s2 #previous pivot is now previous-previous
move $s2, $t5 #location of locked pointer 2, store at s2
sub $s4, $s3, $s2 #the difference of pivot 1  and pivot 2
blt $s4, 2, skipsortingtherightpartwhilesortingtheleftpart

sortLeftsRight:
#--sort right part of the left part
    li $v0, 4
    la $a0, startit
    syscall
    
   move $s7, $s3

   la $t1, ints
   move $t0, $s3
   subi $t0, $t0, 1
   mul $t0, $t0, 4
   add $t1, $t1, $t0
   #our pivot is now on $s1
   lw $s4, 0($t1) #last element of ints, we'll be making good use of offsets for quicksort instead compared to the other previous sorts that makes use of temp memory or using an offset 0 and incrementing 
    li $v0, 4
    la $a0, pivot
    syscall

    li $v0, 1
   move $a0, $s4
   syscall

    li $v0, 11
    la $a0, '\n'
    syscall
    
    # ptr1 starts at first element of subarray (s2+1)
    la $t2, ints
    move $t0, $s2
    addiu $t0, $t0, 1
    mul $t0, $t0, 4
    add $t2, $t2, $t0

# ptr2 starts at previous pivot (s2)
    la $t3, ints
    move $t0, $s2
    mul $t0, $t0, 4
    add $t3, $t3, $t0
    
    move $t0, $s2 #this serves as our counter
    add $t0, $t0, 1
    la $t1, ints
    move $t4, $s2 #locptr1 from s2
    move $t5, $s2 #locptr2 from s2

    #i used zero based indices here btw uwah uwah
quickloopstartlr:
    la $t1, ints
    addiu $t4, $t4, 1 #moveptr1
    li $t7, 0 #innercounter
    li $v0, 4
    la $a0, moveptr1
    syscall
    
printloopqcklr:
    lw $t6, 0($t1)  #get 
    bne $t4, $t7, dontPrintPtr1lr #how specific does my naming have to be?
    li $v0, 4
    la $a0, ptr1
    syscall
 
dontPrintPtr1lr:
    li $v0, 1
    move $a0, $t6
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    bne $t5, $t7, dontPrintPtr2lr #yesnt
    li $v0, 4
    la $a0, ptr2
    syscall
    
dontPrintPtr2lr:
    addiu $t7, $t7, 1
    add $t1, $t1, 4
    beq $t7, 6, comparelr
    j printloopqcklr
    
comparelr:
    li $v0, 11
    la $a0, '\n'
    syscall
    
    la $t1, ints #this is used to reorder base 
    
    li $v0, 4
    la $a0, comparing
    syscall
    
    li $v0, 1
    lw $t7, 0($t2) #get ptr1
    move $a0, $t7
    syscall
    
     li $v0, 4
    la $a0, com_space
    syscall
    
    li $v0, 1
    move $a0, $s4
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    
    ble $t7, $s4, moveptr2funclr
    j skipcomparelr
    
moveptr2funclr:
      addiu $t5 $t5, 1 #moveptr2
      li $v0, 4
      la $a0, moveptr2
     syscall
     
     jal printforquicksort
     
     beqz $t5, dontmovelr #this just means ptr is now on index 0
     add $t3 $t3, 4
dontmovelr:
    #next stepcheck if equal or ahead
      li $v0, 4
      la $a0, ptr2is
     syscall
     lw $t7 0($t3) #get ptr2
     
    li $v0, 1
    move $a0, $t7
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    beq $t4, $t5, skipcomparelr #if they point at the same position, skip else swap
    lw $t8 0($t2) #gets ptr1
    
    li $v0, 4
    la $a0, swapmsg
    syscall
    
    #calculate position of ptr1 and 2
    la $t1, ints
    move $t9, $t4 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t7 0($t1)
    la $t1, ints #this is used to reorder base 
    move $t9, $t5 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t8 0($t1)
    
    jal printforquicksort

skipcomparelr:
    add $t0, $t0, 1
    add $t2 $t2, 4
    li $v0, 11
    la $a0, '\n'
    syscall
    bne $t0, $s7, quickloopstartlr
    
    move $s2, $t5 #location of the new lower point, while there's still a gap continue 
    sub $s4, $s3, $s2 #the difference of pivot 1  and pivot 2
    bge $s4, 2, sortLeftsRight

skipsortingtherightpartwhilesortingtheleftpart:
move $s7, $s2
ble  $s2, 1, quicksortRIGHTSIDEsetup
j quicksortLEFTSIDE

# TAKE NOTE
# s0 - is the location of the first FIXED pivot initially, and will be replaced by the lower bounds accordingly
# s1 - is the value of current pivot
# s2- is the location of previous pivot
# s3- the location of the previous->previous pivot
# s4 - value of the pivot (referring to lr)
# s7 - is where the loop ends (right bound)

quicksortRIGHTSIDEsetup:
  li $s7, 5

quicksortRIGHTSIDE:

    jal checksorted #if its sorted, exit

    li $v0, 4
    la $a0, startit
    syscall

    la $t1, ints
    move $t0, $s7
    mul $t0, $t0, 4
    add $t1, $t1, $t0
    lw $s1, 0($t1)         # $s1 = pivot value

    li $v0, 4
    la $a0, pivot
    syscall
    
    li $v0, 1
    move $a0, $s1
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall

    li $t0, 0 # counter for loop
    la $t2, ints # ptr1
    la $t3, ints # ptr2
    move $t4, $s0 # locptr1 = left bound (pivot just fixed)
    move $t5, $s0 # locptr2 = left bound (pivot just fixed)

    # ptr1 starts at $s0+1
    la $t2, ints
    move $t6, $s0
    addiu $t6, $t6, 1
    mul $t6, $t6, 4
    add $t2, $t2, $t6

    # ptr2 starts at $s0
    la $t3, ints
    move $t6, $s0
    mul $t6, $t6, 4
    add $t3, $t3, $t6

    # Loop from $s0+1 to $s7 (inclusive)
quickloopstartr:
    la $t1, ints
    addiu $t4, $t4, 1 #moveptr1
    li $t7, 0 #innercounter
    li $v0, 4
    la $a0, moveptr1
    syscall

printloopqckr:
    lw $t6, 0($t1)
    bne $t4, $t7, dontPrintPtr1r
    li $v0, 4
    la $a0, ptr1
    syscall
dontPrintPtr1r:
    li $v0, 1
    move $a0, $t6
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    bne $t5, $t7, dontPrintPtr2r
    li $v0, 4
    la $a0, ptr2
    syscall
    
dontPrintPtr2r:
    addiu $t7, $t7, 1
    add $t1, $t1, 4
    beq $t7, 6, comparer
    j printloopqckr

comparer:
    li $v0, 11
    la $a0, '\n'
    syscall

    la $t1, ints
    lw $t8, 0($t2) # get ptr1 value

    li $v0, 4
    la $a0, comparing
    syscall
    
    li $v0, 1
    move $a0, $t8
    syscall
    
    li $v0, 4
    la $a0, com_space
    syscall
    
    li $v0, 1
    move $a0, $s1
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall

    ble $t8, $s1, moveptr2funcr
    j skipcomparer

moveptr2funcr:
    addiu $t5, $t5, 1 #moveptr2
    li $v0, 4
    la $a0, moveptr2
    syscall
    
    jal printforquicksort
    beqz $t5, dontmover
    add $t3, $t3, 4 #moves ptr2's location
    
dontmover:

    li $v0, 4
    la $a0, ptr2is
    syscall
    
    lw $t7, 0($t3) #get's Ptr 2's value
    li $v0, 1
    move $a0, $t7
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall
    
    beq $t4, $t5, skipcomparer #if they are at the same position don't compare
    
    lw $t8, 0($t2) # gets ptr1
    li $v0, 4
    la $a0, swapmsg
    syscall
    
    #calculate position of ptr1 and 2
    la $t1, ints
    move $t9, $t4 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t7 0($t1)
    
    la $t1, ints #this is used to reorder base 
    move $t9, $t5 #gets location of ptr1
    mul $t9, $t9, 4
    add $t1, $t1, $t9 #get offset on ints
    sw $t8 0($t1)

    jal printforquicksort

skipcomparer:
    add $t0, $t0, 1
    add $t2, $t2, 4
    li $v0, 11
    la $a0, '\n'
    syscall
    bne $t4, $s7, quickloopstartr

    # After partition, update pivots and check 
    #at first iteration pivot will always be 5, from here we will continue to loop
    beq $s0, 0, checkdoubleSort
 checkConditions:
    sub $t8, $t5, $s0 #gap between prev pivot and new pivot, if branch is equal or lesser than 2, the numbers between them are sorted such that t5 is our new lower bound
    ble $t8, 2, gapSortedLoopRight
    #else update t5 to be the temporary upper bound
    move $s7, $t5         # new pivot index (locked pointer 2)
    sub $s7, $s7, 1
    jal quicksortRIGHTSIDE
    gapSortedLoopRight:
    move $s0, $t5 #new lower bound
    j quicksortRIGHTSIDE

#now we need to handle when pivot ends up at 4th position (index 3, while lower bound is index 0)!!! the only case where we handle both right's right and right's left at the same time
#the plan of action is to always check what the lower bound is if 0 lead to this
checkdoubleSort:
    beq $s4, 1, rightsRight
    bne $t5, 3, checkConditions
    bne $s7, 5, checkConditions
    li $s4, 1 #this marks that we attempted to sort right's left first
    #we start with sorting right's left by setting our new pivot to index 2
    li $s7, 2
    j quicksortRIGHTSIDE
    
rightsRight:
   #we do right's right which sorts 4 and 5th indices
   li $s0, 4
    li $s7, 5
    j quicksortRIGHTSIDE
    
#================Heap Sort=========================================#
heapsort:
 # First build max heap
    li $v0, 4
    la $a0, heap_building # We organize the heap into a structure max heap
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Start from last parent node ((n/2)-1 where n=6)
    li $t0, 2        # For 6 elements, last parent is at index 2
    li $s0, 6        # Store initial heap size
    
    # Loop: Build the max heap by heapifying all parent nodes.
build_heap:
    # This is where we construct our max heap
    # We start from last parent and work up to root
    move $a0, $t0    # Current parent index
    move $a1, $s0    # Current heap size
    jal heapify      # Call heapify to maintain the max-heap property
    jal print_heap   # Show current heap state
    
    subi $t0, $t0, 1  # Move to the previous parent node
    bge $t0, 0, build_heap # Repeat for all parents (index >= 0)
    
    # Extraction phase: repeatedly remove max and heapify the reduced heap
    move $t0, $s0    # Reset $t0 to heap size (number of items left)
    j extract_loop   # Begin extraction of max elements
    
    # Repeatedly extracts the max element, swaps it to end of the array,
    # heapifies the reduced heap, and prints the steps
extract_loop:
    beqz $t0, heap_sort_done     # If heap size is zero, sorting is done

    # Print extraction step
    li $v0, 4
    la $a0, heap_extract
    syscall
    
    la $t1, ints           # Get base address of the array
    lw $t2, 0($t1)        # $t2 = current root (max element)
    
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Print swap message
    li $v0, 4
    la $a0, swap_root
    syscall
    
    # Swap root with last element
    la $t1, ints          # Base address
    subi $t3, $t0, 1      # Fix: Use size-1 for last element index
    mul $t3, $t3, 4       # Offset = index * 4
    add $t3, $t1, $t3     # Address of last element
    lw $t4, 0($t3)        # $t4 = last element value

    sw $t4, 0($t1)        # Put last element at root
    sw $t2, 0($t3)        # Put old root at end
    
    # Heapify with reduced heap (root, size-1)
    subi $t0, $t0, 1      # Reduce heap size
    move $a1, $t0         # Pass new size to heapify
    move $a0, $zero       # Start heapify from root (index 0)
    jal heapify
    jal print_heap        # Print current heap state after extraction
    
    j extract_loop        # Repeat until heap is empty

# Prints the array as a linear sequence and visualizes the heap
# structure in tree form.
print_heap:
    # Save registers
    addi $sp, $sp, -12
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    li $t0, 0        
    la $t1, ints     
    
    # Print heap array
print_heap_loop:
    beq $t0, 6, print_heap_structure # If we reach 6 elements, print structure
    
    lw $t2, 0($t1)  # Load current element
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t1, $t1, 4     # Move to next element
    addi $t0, $t0, 1
    j print_heap_loop
    
# Visualize the current heap as a tree (level by level)
print_heap_structure:
    # Print heap structure visualization
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Print root level (index 0)
    la $t1, ints
    lw $t2, 0($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Print level 1 (indices 1-2)
    lw $t2, 4($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 4
    la $a0, space
    syscall
    lw $t2, 8($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Print level 2 (indices 3-5)
    lw $t2, 12($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 4
    la $a0, space
    syscall
    lw $t2, 16($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 4
    la $a0, space
    syscall
    lw $t2, 20($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Restore registers
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Maintains the max-heap property for a subtree rooted at index $a0,
# for a heap of size $a1. Recursively pushes down the value if needed.
heapify:
    # a0 = index to start heapifying from
    # a1 = heap size
    
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t2, $a0        # $t2 = current node index
    move $s7, $a1        # $s7 = heap size
    
    # Calculate left and right child indices
    mul $t5, $t2, 2      # $t5 = 2 * index
    addi $t5, $t5, 1     # $t5 = left child index
    mul $t6, $t2, 2      # Right child = 2i + 2
    addi $t6, $t6, 2     # $t6 = right child index
    
    # Find largest
    move $t7, $t2        # Assume root is largest
    
    la $t1, ints
    mul $t3, $t2, 4
    add $t3, $t1, $t3
    lw $t4, 0($t3)       # Root value
    
    # Check if left child is larger
    bge $t5, $s7, check_right    # Skip if beyond heap size
    mul $t8, $t5, 4
    add $t8, $t1, $t8
    lw $t9, 0($t8)                # $t9 = left child value
    ble $t9, $t4, check_right     # Skip if left <= root
    move $t7, $t5                 # Left is largest
    move $t4, $t9                 # Update largest value
    
    # Check if right child is bigger than current largest
check_right:
    bge $t6, $s7, do_swap        # Skip if beyond heap size
    mul $t8, $t6, 4
    add $t8, $t1, $t8
    lw $t9, 0($t8)               # Right child value
    ble $t9, $t4, do_swap        # Skip if right <= largest
    move $t7, $t6                # Right is largest
    
    # Swap root with largest child if necessary and recurse
do_swap:
    beq $t7, $t2, heapify_done   # If root is largest, done
    
    # Swap with largest child
    mul $t8, $t7, 4
    add $t8, $t1, $t8
    lw $t9, 0($t8)               # Load largest child
    mul $t3, $t2, 4
    add $t3, $t1, $t3
    lw $t4, 0($t3)               # Load current
    sw $t9, 0($t3)               # Swap values, Move largest child to root
    sw $t4, 0($t8)               # Move root to child
    
    # Recursively heapify the affected subtree
    move $a0, $t7                # New root index
    move $a1, $s7                # Keep heap size
    jal heapify
    
heapify_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

heap_sort_done:
    j exit

#================Random Sort=========================================#
randomsort:
    # Save return address and used registers
    addi $sp, $sp, -20   # Create stack frame (5 registers × 4 bytes)
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)      # Save shuffle counter
    
    li $s3, 0            # Initialize step counter to track number of steps
    li $t0, 0            # Initialize array index
    la $t1, ints         # Reset array pointer
    
shuffle_loop:
    # Generate random index (0-5)
    li $a1, 6        # Upper bound (exclusive), Set upper bound to 6 (array size)
    li $v0, 42       # System call for random int range
    syscall          # Result in $a0
    
    # Calculate addresses and swap
    mul $t2, $t0, 4     # Current index × 4 (byte offset)
    add $t2, $t1, $t2   # Address of current element
    mul $t4, $a0, 4     # Random index × 4 (byte offset)
    add $t4, $t1, $t4   # Address of random element
    
    # Load values
    lw $t3, 0($t2)   # Load first number, current element
    lw $t5, 0($t4)   # Load second number, random element
    
    # Swap numbers
    sw $t5, 0($t2)   # Store random element in current position
    sw $t3, 0($t4)   # Store current element in random position
    
    addi $s3, $s3, 1    # Increment step counter

    # Print current state
    jal print_current_state

    # Check if sorted
    jal check_if_sorted
    beq $v0, 1, random_sort_done
    
    # Reset array index if we reached the end
    addi $t0, $t0, 1
    blt $t0, 6, shuffle_loop
    li $t0, 0            # Reset only when we've gone through whole array
    
    # Try again if not sorted
    j shuffle_loop

random_sort_done:
    # Print number of steps taken
    li $v0, 4
    la $a0, steps_msg
    syscall
    
    li $v0, 1
    move $a0, $s3      # Print total steps counter
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall

    # Restore saved registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)    # Don't forget to restore step counter
    addi $sp, $sp, 20  # Adjust stack pointer (changed from 16 to 20)
    j exit

check_if_sorted:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)   # Save return address
    
    la $t6, ints     # Load array base
    li $t7, 0        # Counter
    li $v0, 1        # Assume sorted 1 = true

check_loop:
    lw $t8, 0($t6)   # Current number
    lw $t9, 4($t6)   # Next number
    
    bgt $t8, $t9, not_sorted  # If current > next, not sorted
    
    addi $t6, $t6, 4  # Move to next pair
    addi $t7, $t7, 1  
    blt $t7, 5, check_loop # Continue until we check all pairs (5 pairs for 6 elements)
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

not_sorted:
    li $v0, 0        # Mark as not sorted
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

print_current_state:
    # Save return address and used registers
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    la $t6, ints
    li $t7, 0
    
print_loop:
    beq $t7, 6, print_done  # Exit if printed all elements
    
    lw $t8, 0($t6)          # Load current number
    
    li $v0, 1               # System call for print integer
    move $a0, $t8           # System call for print integer
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t6, $t6, 4
    addi $t7, $t7, 1
    j print_loop
    
print_done:
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Restore registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

#=================Radix Sort=========================================#
# Find maximum number to determine number of required passes
find_max:
    # Find maximum number to determine number of digits
    la $t1, ints
    li $t2, 0    # Max number 
    li $t0, 0    # Counter

# Loop through array to find maximum value
max_loop:
    lw $t3, 0($t1) # Load current number
    bgt $t3, $t2, update_max # If current > max, update max
    j continue_max

update_max:
    move $t2, $t3 # Update max value

continue_max:
    addi $t1, $t1, 4 # Move to next array element
    addi $t0, $t0, 1 # Increment counter
    blt $t0, 6, max_loop # Continue if not done with array

    # Calculate number of digits in max number
    move $t3, $t2 # Copy max number for digit counting
    li $s1, 0     # Digit counter

    # Loop to count digits by repeatedly dividing by 10
count_digits:
    beqz $t3, start_radix # If number becomes 0, start sorting
    div $t3, $t3, 10 # Divide by 10
    addi $s1, $s1, 1 # Increment digit count
    j count_digits

start_radix:
    li $s0, 1    # Current digit position (1, 10, 100), Start with ones place (10^0)

# Main radix sort loop - process each digit position
radix_loop:
    # If we've completed s1 passes, we are done with Radix Sort
    beqz $s1, done_radix # If no more digits to process, we're done

    # Print current digit position
    li $v0, 4
    la $a0, radix_msg
    syscall
    
    li $v0, 1
    move $a0, $s0
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall

    # Print bucket header
    li $v0, 4
    la $a0, bucket_msg
    syscall

    # Clear count array (count[i]=0 for i=0..9), for next digit position
    la   $t9, count # Array to count occurrences of each digit (0-9)
    li   $t8, 0     # Counter for clearing arrays

clear_count_loop:
    sw   $zero, 0($t9)    # count[i] = 0
    addi $t9, $t9, 4      # Move to next count array element
    addi $t8, $t8, 1      # Increment
    blt  $t8, 10, clear_count_loop

    # Clear buckets memory
    la   $t9, buckets # Array for sorting buckets
    li   $t8, 0       # Counter for clearing buckets

clear_buckets_loop:
    sw   $zero, 0($t9)  # Clear bucket entry
    addi $t9, $t9, 4    # Move to next bucket position
    addi $t8, $t8, 1    # Increment counter
    blt  $t8, 60, clear_buckets_loop

    # Distribute elements into buckets
    la   $t1, ints
    li   $t0, 0          # loop counter for 6 elements

# Distribute numbers into buckets based on current digit
distribute_loop:
    lw   $t2, 0($t1)     # Load current element
    
    # Calculate digit = (element / s0) % 10
    div  $t5, $t2, $s0   # t5 = element / digitPos
    mflo $t5             # quotient
    li   $t6, 10         # divisor for mod operation
    div  $t5, $t5, $t6   # get remainder
    mfhi $t3             # bucketIndex in t3

    # Get count for that bucket
    la   $t7, count
    sll  $t8, $t3, 2     # 4*bucketIndex
    add  $t7, $t7, $t8
    lw   $t9, 0($t7)     # count[bucketIndex]

    # Store element in correct bucket position
    la   $t4, buckets     # Base address of buckets
    li   $s2, 24          # 24 bytes per bucket (6 items * 4 bytes)
    mul  $t8, $t3, $s2    # offset for bucket
    add  $t4, $t4, $t8    # and get to the right bucket

    # Offset inside bucket
    mul  $t8, $t9, 4     # 4 bytes per element
    add  $t4, $t4, $t8
    
    sw   $t2, 0($t4)     # store element
    
    # Increment count[bucketIndex]
    addi $t9, $t9, 1
    sw   $t9, 0($t7)

    # Next element
    addi $t1, $t1, 4
    addi $t0, $t0, 1
    blt  $t0, 6, distribute_loop

    # Print bucket contents
    li   $v0, 4
    la   $a0, bucket_msg
    syscall

    # Print each bucket (0..9)
    li   $t3, 0         # bucket index

print_buckets_loop:
    bge  $t3, 10, skip_bucket_print

    # Select correct bucket label
    la   $s2, bucket0
    move $t4, $t3
    beq  $t4, 0, print_bkt0
    beq  $t4, 1, print_bkt1
    beq  $t4, 2, print_bkt2
    beq  $t4, 3, print_bkt3
    beq  $t4, 4, print_bkt4
    beq  $t4, 5, print_bkt5
    beq  $t4, 6, print_bkt6
    beq  $t4, 7, print_bkt7
    beq  $t4, 8, print_bkt8
    beq  $t4, 9, print_bkt9
    j    got_label

print_bkt0: la $s2, bucket0
    j got_label
print_bkt1: la $s2, bucket1
    j got_label
print_bkt2: la $s2, bucket2
    j got_label
print_bkt3: la $s2, bucket3
    j got_label
print_bkt4: la $s2, bucket4
    j got_label
print_bkt5: la $s2, bucket5
    j got_label
print_bkt6: la $s2, bucket6
    j got_label
print_bkt7: la $s2, bucket7
    j got_label
print_bkt8: la $s2, bucket8
    j got_label
print_bkt9: la $s2, bucket9

got_label:
    # Print bucket label
    li   $v0, 4
    move $a0, $s2
    syscall

    # Get number of items in this bucket
    la   $t6, count
    sll  $t7, $t3, 2
    add  $t6, $t6, $t7
    lw   $t9, 0($t6)    # numberOfItems

    # Print items in bucket
    la   $t6, buckets
    li   $s2, 24
    mul  $t7, $t3, $s2
    add  $t6, $t6, $t7  # start of bucket
    li   $t4, 0         # index in bucket

print_each_item:
    beq  $t4, $t9, end_bucket
    
    lw   $t5, 0($t6)
    # Print number
    li   $v0, 1
    move $a0, $t5
    syscall

    # Print space
    li   $v0, 4
    la   $a0, space
    syscall

    addi $t4, $t4, 1
    addi $t6, $t6, 4
    j    print_each_item

end_bucket:
    # Print newline
    li   $v0, 11
    li   $a0, '\n'
    syscall

    addi $t3, $t3, 1
    j    print_buckets_loop

skip_bucket_print:
    # Collect numbers back into array
    la   $t1, ints      # destination array
    li   $t2, 0         # bucket index
    li   $t0, 0         # total items counter

collect_numbers_loop:
    bge  $t2, 10, collect_done
    
    # Get count[t2]
    la   $t3, count
    sll  $t4, $t2, 2
    add  $t3, $t3, $t4
    lw   $t5, 0($t3)    # items in bucket t2

    beq  $t5, $zero, next_bucket

    # Get bucket address
    la   $t6, buckets
    li   $s2, 24
    mul  $t4, $t2, $s2
    add  $t6, $t6, $t4

    # Copy items from bucket
    li   $t4, 0

copy_bucket_items:
    beq  $t4, $t5, finish_this_bucket
    lw   $t7, 0($t6)
    sw   $t7, 0($t1)
    addi $t6, $t6, 4
    addi $t1, $t1, 4
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j    copy_bucket_items

finish_this_bucket:
next_bucket:
    addi $t2, $t2, 1
    j    collect_numbers_loop

collect_done:
    # Print array after this pass
    li   $v0, 4
    la   $a0, after_pass
    syscall

    # Print current array state
    li   $t0, 0
    la   $t1, ints

print_pass_array:
    beq  $t0, 6, pass_array_newline
    lw   $t2, 0($t1)
    
    li   $v0, 1
    move $a0, $t2
    syscall

    li   $v0, 4
    la   $a0, com_space
    syscall

    addi $t1, $t1, 4
    addi $t0, $t0, 1
    j    print_pass_array

pass_array_newline:
    li   $v0, 11
    li   $a0, '\n'
    syscall

    # Prepare for next pass
    li   $t2, 10
    mul  $s0, $s0, $t2
    addi $s1, $s1, -1
    j    radix_loop

done_radix:
    j exit
#--- Exit Area for All Sorts---
#Final Printing
exit:
       li $v0, 4
       la $a0, res
       syscall

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
    j endprogram

printforquicksort:
 #i used zero based indices here btw uwah uwah
    la $t1, ints
    li $t7, 0 #innercounter
    
printloopqck2:
    lw $t6, 0($t1)  #get 
    bne $t4, $t7, dontPrintPtr12 #how specific does my naming have to be?
    li $v0, 4
    la $a0, ptr1
    syscall
 
dontPrintPtr12:
    li $v0, 1
    move $a0, $t6
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    bne $t5, $t7, dontPrintPtr22#yesnt
    li $v0, 4
    la $a0, ptr2
    syscall
    
dontPrintPtr22:
    addiu $t7, $t7, 1
    add $t1, $t1, 4
    bne $t7, 6, printloopqck2
    
    li $v0, 11
    la $a0, '\n'
    syscall
    
    jr $ra
    
checksorted:
                li $t0, 0
   		 la $t1, ints         # start of array
	checkloop2:
    		lw $t6, 0($t1)       # load current element
  		lw $t7, 4($t1)       # load next element

    		bgt $t6, $t7, outoforder2  # if out of order, start sorting

 		addi $t1, $t1, 4     # move to next pair
   		addi $t0, $t0, 1
    		blt $t0, 5, checkloop2

    		# If reached here, it's sorted already
    		 li $t0, 0 #counter
   		 la $t1, ints #integers
    		syscall
    		j exit
    	outoforder2:
    		jr $ra
    		
# isValidInt: Checks if string in $a0 is a valid integer
# it returns eturns $v0 = 1 if valid, 0 if not

isValidInt:
    # $a0 = address of string
    # $v0 = 1 if valid, 0 if not
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t1, 4($sp)

    move $t0, $a0
    lb $t1, 0($t0) #get first elem
    beq $t1, 0x0A, invalidint   # empty input (newline)
    beq $t1, 0, invalidint      # empty input (null)

    # Optional leading minus
    li $v0, 1
    li $t2, 45                  # '-'
    beq $t1, $t2, skip_first
    j check_digits

skip_first:
    addi $t0, $t0, 1
    lb $t1, 0($t0)
    beq $t1, 0x0A, invalidint  # only '-' is invalid
    beq $t1, 0, invalidint

check_digits:
    # Loop through each character
check_digit_loop:
    lb $t1, 0($t0)
    beq $t1, 0x0A, validint    # newline: end of input
    beq $t1, 0, validint       # null: end of input
    blt $t1, 48, invalidint    # not '0'-'9'
    bgt $t1, 57, invalidint
    addi $t0, $t0, 1
    j check_digit_loop

validint:
    li $v0, 1
    j is_valid_int_end

invalidint:
    li $v0, 0

is_valid_int_end:
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# str2int: Converts string in $a0 to integer, returns in $v0
# Handles optional leading minus
str2int:
    addi $sp, $sp, -12
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)

    move $t0, $a0
    li $v0, 0
    li $t2, 1                  # sign = 1

    lb $t1, 0($t0)
    li $t3, 45                 # '-'
    bne $t1, $t3, str2int_loop
    li $t2, -1                 # sign = -1
    addi $t0, $t0, 1

str2int_loop:
    lb $t1, 0($t0)
    beq $t1, 0x0A, str2int_done
    beq $t1, 0, str2int_done
    sub $t1, $t1, 48           # char to int
    mul $v0, $v0, 10
    add $v0, $v0, $t1
    addi $t0, $t0, 1
    j str2int_loop

str2int_done:
    mul $v0, $v0, $t2          # apply sign

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
endprogram:
    li $v0, 10
    syscall
