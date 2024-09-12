//This code is supposed to test some of the interrupt features
//of the architecture. It should test the  
LDW @1 @0 .var

CALLR @5 16	//not sure if there is a simpler way but these instructions
ADD @0 @0 @0	//are supposed to activate the interrupt enable bit
JMPR ALWAYS 12
ADD @0 @0 @0
RETI @5 0
ADD @0 @0 @0

CALL @31 @0 :fillWindow
ADD @0 @0 @0
.word var #89ABCDE0

:fillWindow
ADD @16 @1 #1
ADD @17 @1 #2
ADD @18 @1 #3
ADD @19 @1 #4
ADD @20 @1 #5
ADD @21 @1 #6
ADD @22 @1 #7
ADD @23 @1 #8
ADD @24 @1 #9
ADD @25 @1 #a
ADD @26 @1 #b
ADD @27 @1 #c
ADD @28 @1 #d
ADD @29 @1 #e
ADD @30 @1 #f
ADD @2 @0 1	//this is a counter to test if we already had overflown the Register File
SUB @0 @2 8	//compare to check if its equal to 8
JMPR EQUAL 16	//if its equal to 8, we return with a reti to reactivate the interrupt enable bit
ADD @0 @0 @0
CALL @31 @0 :fillWindow
ADD @0 @0 @0
RETI @31 @0 0
