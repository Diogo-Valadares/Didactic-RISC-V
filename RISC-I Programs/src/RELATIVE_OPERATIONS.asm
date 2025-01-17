JMP ALWAYS R0 :start
ADD R0 R0 R0
.word var #FFFFFFFF
:start
LDRW R1 #FFFFFFFC //load the information present in 4 bytes before the address of this instruction
STRB R1 #00000100 //test if it writes correctly 100(hex) addresses after the address of this instruction
STRB R1 #00000102
STRS R1 #00000100
STRS R1 #00000101
STRW R1 #00000100

JMPR ALWAYS #10
ADD R0 R0 R0
ADD R2 R2 #FF
ADD R3 R3 #FF
ADD R4 R4 #FF //should be the only add being executed
CALLR R5 #10
ADD R0 R0 R0
ADD R6 R6 #FF
ADD R7 R7 #FF
ADD R8 R8 #FF //should be the only add being executed

JMPR ALWAYS 0 //jumps to itself and creates an infinite loop
ADD R0 R0 R0