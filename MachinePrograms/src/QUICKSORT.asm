ADD R0 R0 0
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
.word element1 	#6
.word element2 	#4
.word element3 	#5
.word element4 	#2
.word element5 	#3
.word element6 	#1
.word element7 	#9
.word element8 	#F
.word element9 	#A
.word element10 #3
.word element11 #C
.word element12 #6
.word element13 #3
.word element14 #0
.word element15 #8
//.word element16 #9
//.word element17 #3
//.word element18 #6
//.word element19 #C
//.word element20 #E
//.word element21 #E
//.word element22 #F
//.word element23 #4
//.word element24 #2
//.word element25 #1
//.word element26 #9
//.word element27 #3
//.word element28 #0
//.word element29 #6
:arrayEnd
.word element30 #2