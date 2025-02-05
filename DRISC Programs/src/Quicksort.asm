lw t0 zero .basePointer
lw t1 zero .arrayEnd
lui sp 0xf0				//inicializing stack pointer

mv a0 t0				//array address
mv a1 zero				//low index, starts as 0
sub a2 t1 t0			//high index, starts as the last index

call :quickSort			//


jump 0 					//program end


#REGION quicksort
:quickSort
addi sp sp -20			//alocate 5 words of space
sw ra sp 16				//Saves the registers that will be used
sw s3 sp 12			
sw s2 sp 8
sw s1 sp 4
sw s0 sp 0

mv s0 a0				//Passes the input arguments to the
mv s1 a1				//Saved Registers
mv s2 a2

bge s1 s2 :end_quick_sort //if low >= high, return


call :partition			//p = partition(low,high);
mv s3 a3				//

mv a3 s0				//array address
mv a1 s1				//low
addi a2 s3 -4			//pivot - 1			
call :quickSort			//quicksort(array, low, pivot - 1)


mv a3 s0				//array address
addi a1 s3 4			//pivot + 1
mv a2 s2				//high	
call :quickSort			//quickSort(array, pivot+1, high)


:end_quick_sort
lw s0 sp 0				//loads the saved registers from the
lw s1 sp 4				//lower window
lw s2 sp 8
lw s3 sp 12
lw ra sp 16
addi sp sp 20			//desalocate the 5 words
ret

#ENDREGION

#REGION partition
:partition//translated from https://www.geeksforgeeks.org/quick-sort-algorithm/
add t0 a0 a2			//&arr + high
lw t0 t0 0				//pivot = arr[high]
addi t1 a1 -4			//i = low - 1

mv t2 a1				//for(j = low;..
addi s9 a2 -4			//high - 1;
:for_start
bgt t1 s9 :for_end		//..;j <= high - 1;..

add t4 a0 t2			//&arr + j
lw t6 t4 0				//arr[j]
nop
bge t6 t0 :end_if		//if(arr[j] < pivot){

addi t1 t1 4			//i++;
//swap
add t3 a0 t1			//&arr + i
lw t5 t3 0				//arr[i]
sw t6 t3 0				//arr[i] = j
sw t5 t4 0				//arr[j] = i
:end_if
addi t2 t2 4			//..;j++){
jump :for_start

:for_end

//last swap
addi t1 t1 4			//i+1;
add t3 a0 t1			//&arr+i+1
lw t5 t3 0				//arr[i+1]
add t4 a0 a2			//&arr + high
lw t6 t4 0				//arr[high]
sw t5 t4 0				//arr[high] = i+1
sw t6 t3 0				//arr[i+1] = high

addi a3 t1 4			//return i+1 as the position of the pivot
ret


#ENDREGION

#REGION data
.word basePointer :arrayStart
.word arrayEnd :arrayEnd

.word padding0 0x00000000
.word padding1 0x00000000
.word padding2 0x00000000

:arrayStart
.word element0 0xA1B2C3D4
.word element1 0x1E2F3A4B
.word element2 0x4C5D6E7F
.word element3 0xF0E1D2C3
.word element4 0x7A8B9C0D
.word element5 0x12345678
:arrayEnd
.word element6 0x9ABCDEF0
//.word element7 0x0FEDCBA9
//.word element8 0x89ABCDEF
//.word element9 0x76543210
//.word element10 0xBA98DCFE
//.word element11 0x13579BDF
//.word element12 0x2468ACE0
//.word element13 0xACE1B2D3
//.word element14 0xB1C2D3E4
//.word element15 0xC0F1E2D3
//.word element16 0xD4E5F6A7
//.word element17 0xE6F7A8B9
//.word element18 0xF8A9B0C1
//.word element19 0xA0B1C2D3
//.word element20 0x1234ABCD
//.word element21 0x0A1B2C3D
//.word element22 0xFEDCBA98
//.word element23 0x7654FEDC
//.word element24 0x89ABCDE0
//.word element25 0x56789ABC
//.word element26 0x1D2C3B4A
//.word element27 0x2E3D4A5B
//.word element28 0x3F4A5B6C
//.word element29 0x4E5F6A7B
//.word element30 0x5A6B7C8D
//.word element31 0x6C7D8E9F
