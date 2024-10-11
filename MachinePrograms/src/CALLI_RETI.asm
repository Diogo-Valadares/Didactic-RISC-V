//This code is supposed to test some of the interrupt features
//of the architecture. It should test the  
ldw R1 R0 .var

callr R5 16	//not sure if there is a simpler way but these instructions
add R0 R0 R0	//are supposed to activate the interrupt enable bit
jmpr always 12
add R0 R0 R0
reti R5 0
add R0 R0 R0

call R31 R0 :fillWindow
add R0 R0 R0
.word var #89ABCDE0

:fillWindow
add R16 R1 #1
add R17 R1 #2
add R18 R1 #3
add R19 R1 #4
add R20 R1 #5
add R21 R1 #6
add R22 R1 #7
add R23 R1 #8
add R24 R1 #9
add R25 R1 #a
add R26 R1 #b
add R27 R1 #c
add R28 R1 #d
add R29 R1 #e
add R30 R1 #f
add R2 R0 1	//this is a counter to test if we already had overflown the Register File
sub R0 R2 8	//compare to check if its equal to 8
jmpr equal 16	//if its equal to 8, we return with a reti to reactivate the interrupt enable bit
add R0 R0 R0
call R31 R0 :fillWindow
add R0 R0 R0
reti R31 R0 0
