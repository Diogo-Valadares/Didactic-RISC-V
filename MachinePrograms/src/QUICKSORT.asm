ADD R0 R0 0

callr R5 16	    //activating interruptions incase of a window overflow
add R0 R0 R0	
jmpr always 16
add R0 R0 R0
reti R0 R5 0
add R0 R0 R0

LDW R1 R0 .basePointer	//the array start and end will be global variables
LDW R2 R0 .arrayEnd

ADD R26 R1 0			//R16 is the low index passed to the quickSort function
ADD R27 R2 0			//R17 is the high index passed to the quickSort function
CALL R31 R0 :quickSort
ADD R0 R0 0

JMPR ALWAYS 0
ADD R0 R0 0

//********************************************************************************//

:quickSort
SUB R0 R10 R11 			//if low >= high, return
JMP GREATER_EQUAL R0 :endQuickSort
ADD R0 R0 0

ADD R26 R10 0			//passing low and high to the partition function
ADD R27 R11 0			
CALL R31 R0 :partition	//the partition will return the pivot at register R28
ADD R0 R0 0
ADD R16 R28 0			//p = partition();

ADD R5 R0 3 //3 indicates its searching the left
//Quicksort on the left
ADD R26 R10 0			//low
SUB R27 R16 4			//pivot - 1			
CALL R31 R0 :quickSort
ADD R0 R0 0

ADD R5 R0 5 //5 indicates its searching the right
//Quicksort on the right
ADD R26 R16 4			//pivot + 1
ADD R27 R11 0			//high	
CALL R31 R0 :quickSort
ADD R0 R0 0

:endQuickSort
RET R0 R0 R31
ADD R0 R0 0

//********************************************************************************//

:partition
LDW R18 R11 0			//Initialize pivot to be the highest element: pivot = array[high]

SUB R16 R10 4			// i = low - 1 //pointer for the greater element
SUB R17 R10 0			// j = low

JMP ALWAYS R0 :partitionForLoopComparison
ADD R0 R0 0

:partitionForLoopStart

LDW R19 R17 0			//array[j]
SUB R20 R19 R18			//array[j] <= pivot
JMP GREATER R0 :partitionIfEnd //if array[j] <= pivot swap with i
ADD R0 R0 0

ADD R16 R16 4			//i++

ADD R26 R16 0			//passing address of i to swap
ADD R27 R17 0			//passing address of j to swap
CALL R31 R0 :swap		//swap(array[i], array[j])
ADD R0 R0 0
:partitionIfEnd

ADD R17 R17 4			//j++
:partitionForLoopComparison
SUB R0 R17 R11			//while j < high
JMP LESS R0 :partitionForLoopStart
ADD R0 R0 0

ADD R26 R16 4			//passing address of i to swap
ADD R27 R11 0			//passing address of high(pivot) to swap
CALL R31 R0 :swap		//Swapping pivot with the greater element at i
ADD R0 R0 0

ADD R12 R16 4			//return i+1 as the position of the pivot
RET R0 R0 R31
ADD R0 R0 0
//********************************************************************************//

:swap
LDW R20 R10 0			//R20 = array[i]
LDW R21 R11 0			//R21 = array[j]
STW R20 R11 0			//array[i] = R21
STW R21 R10 0			//array[j] = R20
RET R0 R0 R31
ADD R0 R0 0

.word basePointer :arrayStart
.word arrayEnd :arrayEnd

.word padding0 	#00000000
.word padding1 	#00000000
.word padding2 	#00000000
				
:arrayStart		
.word element0 #A1B2C3D4
.word element1 #1E2F3A4B
.word element2 #4C5D6E7F
.word element3 #F0E1D2C3
.word element4 #7A8B9C0D
.word element5 #12345678
.word element6 #9ABCDEF0
.word element7 #0FEDCBA9
.word element8 #89ABCDEF
.word element9 #76543210
.word element10 #BA98DCFE
.word element11 #13579BDF
.word element12 #2468ACE0
.word element13 #ACE1B2D3
.word element14 #B1C2D3E4
.word element15 #C0F1E2D3
.word element16 #D4E5F6A7
.word element17 #E6F7A8B9
.word element18 #F8A9B0C1
.word element19 #A0B1C2D3
.word element20 #1234ABCD
.word element21 #0A1B2C3D
.word element22 #FEDCBA98
.word element23 #7654FEDC
.word element24 #89ABCDE0
.word element25 #56789ABC
.word element26 #1D2C3B4A
.word element27 #2E3D4A5B
.word element28 #3F4A5B6C
.word element29 #4E5F6A7B
.word element30 #5A6B7C8D
:arrayEnd
.word element31 #6C7D8E9F