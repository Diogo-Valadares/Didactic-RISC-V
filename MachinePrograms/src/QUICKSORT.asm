ADD @0 @0 0
LDW @1 @0 .basePointer	//the array start and end will be global variables
LDW @2 @0 .arrayEnd

ADD @26 @1 0			//@16 is the low index passed to the quickSort function
ADD @27 @2 0			//@17 is the high index passed to the quickSort function
CALL @31 @0 :quickSort
ADD @0 @0 0

JMPR ALWAYS 0
ADD @0 @0 0

//********************************************************************************//

:quickSort
SUB @0 @10 @11 			//if low >= high, return
JMP GREATER_EQUAL @0 :endQuickSort
ADD @0 @0 0

ADD @26 @10 0			//passing low and high to the partition function
ADD @27 @11 0			
CALL @31 @0 :partition	//the partition will return the pivot at register @28
ADD @0 @0 0
ADD @16 @28 0			//p = partition();

ADD @5 @0 3 //3 indicates its searching the left
//Quicksort on the left
ADD @26 @10 0			//low
SUB @27 @16 4			//pivot - 1			
CALL @31 @0 :quickSort
ADD @0 @0 0

ADD @5 @0 5 //5 indicates its searching the right
//Quicksort on the right
ADD @26 @16 4			//pivot + 1
ADD @27 @11 0			//high	
CALL @31 @0 :quickSort
ADD @0 @0 0

:endQuickSort
RET @0 @0 @31
ADD @0 @0 0

//********************************************************************************//

:partition
LDW @18 @11 0			//Initialize pivot to be the highest element: pivot = array[high]

SUB @16 @10 4			// i = low - 1 //pointer for the greater element
SUB @17 @10 0			// j = low

JMP ALWAYS @0 :partitionForLoopComparison
ADD @0 @0 0

:partitionForLoopStart

LDW @19 @17 0			//array[j]
SUB @20 @19 @18			//array[j] <= pivot
JMP GREATER @0 :partitionIfEnd //if array[j] <= pivot swap with i
ADD @0 @0 0

ADD @16 @16 4			//i++

ADD @26 @16 0			//passing address of i to swap
ADD @27 @17 0			//passing address of j to swap
CALL @31 @0 :swap		//swap(array[i], array[j])
ADD @0 @0 0
:partitionIfEnd

ADD @17 @17 4			//j++
:partitionForLoopComparison
SUB @0 @17 @11			//while j < high
JMP LESS @0 :partitionForLoopStart
ADD @0 @0 0

ADD @26 @16 4			//passing address of i to swap
ADD @27 @11 0			//passing address of high(pivot) to swap
CALL @31 @0 :swap		//Swapping pivot with the greater element at i
ADD @0 @0 0

ADD @12 @16 4			//return i+1 as the position of the pivot
RET @0 @0 @31
ADD @0 @0 0
//********************************************************************************//

:swap
LDW @20 @10 0			//R20 = array[i]
LDW @21 @11 0			//R21 = array[j]
STW @20 @11 0			//array[i] = R21
STW @21 @10 0			//array[j] = R20
RET @0 @0 @31
ADD @0 @0 0

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