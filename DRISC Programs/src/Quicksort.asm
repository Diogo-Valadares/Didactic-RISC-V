nop
lw t0 zero .basePointer
lw t1 zero .arrayEnd
lui sp 0xf				//inicializing stack pointer

mv a0 t0				//array address
mv a1 zero				//low index, starts as 0
sub a2 t1 t0			//high index, starts as the last index
dec a2 1

call :quickSort			//


jump 0 					//program end


#REGION quicksort
:quickSort
bge a1 a2 :end_quick_sort //if low >= high, return

dec sp 16				//alocate 5 words of space
sw ra sp 12				//Saves the registers that will be used
sw s3 sp 8			
sw s2 sp 4
sw s1 sp 0

mv s1 a1				//Passes the input arguments to the
mv s2 a2				//Saved Registers

call :partition			//p = partition(low,high);
mv s3 a3				//

mv a1 s1				//low
addi a2 s3 -1			//pivot - 1			
call :quickSort			//quicksort(array, low, pivot - 1)
addi a1 s3 1			//pivot + 1
mv a2 s2				//high	
call :quickSort			//quickSort(array, pivot+1, high)
	
lw s1 sp 0				//loads the saved registers from the
lw s2 sp 4				//lower window
lw s3 sp 8
lw ra sp 12
inc sp 16				//desalocate the 5 words

:end_quick_sort	
ret

#ENDREGION

#REGION partition
:partition//translated from https://www.geeksforgeeks.org/quick-sort-algorithm/
add t0 a0 a2			//&arr + high
lb t0 t0 0				//pivot = arr[high]
addi t1 a1 -1			//i = low - 1

mv t2 a1				//for(j = low;..
addi s9 a2 -1			//high - 1;
:for_start
bgt t2 s9 :for_end		//..;j <= high - 1;..

add t4 a0 t2			//&arr + j
lb t6 t4 0				//arr[j]
nop
bge t6 t0 :end_if		//if(arr[j] < pivot){

inc t1 1			//i++;
//swap
add t3 a0 t1			//&arr + i
lb t5 t3 0				//arr[i]
sb t6 t3 0				//arr[i] = j
sb t5 t4 0				//arr[j] = i
:end_if
inc t2 1			//..;j++){
jump :for_start

:for_end

//last swap
addi t1 t1 1			//i+1;
add t3 a0 t1			//&arr+i+1
lb t5 t3 0				//arr[i+1]
add t4 a0 a2			//&arr + high
lb t6 t4 0				//arr[high]
sb t5 t4 0				//arr[high] = i+1
sb t6 t3 0				//arr[i+1] = high

mv a3 t1				//return i+1 as the position of the pivot
ret


#ENDREGION

#REGION data

.word basePointer :arrayStart
.word arrayEnd :arrayEnd

.word padding0 0x00000000
.word padding1 0x00000000
.word padding2 0x00000000
.word padding3 0x00000000

:arrayStart
.word element0 0xAA99CC77
.word element1 0xEE33FF00
.word element2 0xDD112244
.word element3 0x8855BB66
:arrayEnd