NOP

LW t0 zero .basePointer
LW t1 zero .arrayEnd
ADDI sp sp 0x7ff		//inicializing stack pointer

MV a0 t0				//array address
MV a1 zero				//low index, starts as 0
SUB a2 t1 t0			//high index, starts as the last index

CALL :quickSort			//
NOP

JUMP 0 					//program end
NOP

#REGION quicksort

addi sp sp -20			//alocate 5 words of space
sw ra sp 16				//Saves the registers that will be used
sw s3 sp 12			
sw s2 sp 8
sw s1 sp 4
sw s0 sp 0

MV s0 a0				//Passes the input arguments to the
MV s1 a1				//Saved Registers
MV s2 a2

:quickSort
BGE a1 a2 :endQuickSort //if low >= high, return
NOP

CALL :partition			//p = partition(low,high);
MV s3 a0				//

ADDI tp zero 3 			//DEBUG 3 indicates its searching the left						

MV a0 s0				//array address
MV a1 s1				//low
ADDI a2 s3 -4			//pivot - 1			
CALL :quickSort			//quicksort(array, low, pivot - 1)
NOP

ADDI tp zero 5 			//DEBUG 5 indicates its searching the right
MV a0 s0				//array address
ADDI a1 s3 4			//pivot + 1
MV a2 s2				//high	
CALL :quickSort			//quickSort(array, pivot+1, high)
NOP

:endQuickSort
LW s0 sp 0				//loads the saved registers from the
LW s1 sp 4				//lower window
LW s2 sp 8
LW s3 sp 12
LW ra sp 16
ADDI sp sp 20			//desalocate the 5 words
RET
NOP
#ENDREGION

#REGION partition
:partition
ADD t0 a0 a1 			//address of the array start(low)
ADD t1 a0 a2			//address of the array end(high)

LW t2 t1 0				//pivot = array[high]; Initialize pivot to be the highest element

ADDI t3 t0 -4			// i = low - 1 //pointer for the greater element
MV t4 t0				// j = low

JUMP :partition_loop_compare
NOP

:partition_loop_start

LW t5 t4 0				//array[j]
BGT t5 t2 :partition_if_end //if array[j] <= pivot swap with i
NOP

ADDI t3 t3 4			//i++	
LW t6 t3 0				//t6 = array[i]

SW t5 t3 0				//array[i] = t5
SW t6 t4 0				//array[j] = t6

:partition_if_end

ADDI t4 t4 4			//j++
:partition_loop_compare
BLT t4 t1 :partition_loop_start //while j < high
NOP

LW t6 t3 0				//t6 = array[i]

SW t5 t3 0				//array[i] = t5 (array[j])
SW t6 t4 0				//array[j] = t6 (array[i])

SUB t3 t3 a0			//subtracting the address of the array from i
ADDI a0 t3 4				//return i+1 as the position of the pivot
RET
NOP

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
.word element7 0x0FEDCBA9
.word element8 0x89ABCDEF
.word element9 0x76543210
.word element10 0xBA98DCFE
.word element11 0x13579BDF
.word element12 0x2468ACE0
.word element13 0xACE1B2D3
.word element14 0xB1C2D3E4
.word element15 0xC0F1E2D3
.word element16 0xD4E5F6A7
.word element17 0xE6F7A8B9
.word element18 0xF8A9B0C1
.word element19 0xA0B1C2D3
.word element20 0x1234ABCD
.word element21 0x0A1B2C3D
.word element22 0xFEDCBA98
.word element23 0x7654FEDC
.word element24 0x89ABCDE0
.word element25 0x56789ABC
.word element26 0x1D2C3B4A
.word element27 0x2E3D4A5B
.word element28 0x3F4A5B6C
.word element29 0x4E5F6A7B
.word element30 0x5A6B7C8D
.word element31 0x6C7D8E9F
