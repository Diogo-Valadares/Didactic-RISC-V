//This code is supposed to test some of the interrupt features
//of the architecture.
add R0 R0 R0
ldw R1 R0 .var

callr R5 16	    //not sure if there is a simpler way but these instructions
add R0 R0 R0	//are supposed to activate the interrupt enable bit
jmpr always 16
add R0 R0 R0
reti R0 R5 0
add R0 R0 R0

:fillWindow

add R2 R2 R1  
add R10 R2 0
add R2 R2 R1  
add R11 R2 0
add R2 R2 R1  
add R12 R2 0
add R2 R2 R1  
add R13 R2 0
add R2 R2 R1  
add R14 R2 0
add R2 R2 R1  
add R15 R2 0

add R2 R2 R1  
add R16 R2 0
add R2 R2 R1  
add R17 R2 0
add R2 R2 R1  
add R18 R2 0
add R2 R2 R1  
add R19 R2 0
add R2 R2 R1  
add R20 R2 0
add R2 R2 R1  
add R21 R2 0
add R2 R2 R1  
add R22 R2 0
add R2 R2 R1  
add R23 R2 0
add R2 R2 R1  
add R24 R2 0
add R2 R2 R1  
add R25 R2 0

call R31 R0 :fillWindow
add R0 R0 R0
.word var #00010001