LDW R9 R0 .option
SUB R0 R9 0
JMP EQUAL R0 :incrementCNZV
SUB R0 R9 1
JMP EQUAL R0 :incrementSavedWindow
SUB R0 R9 2
JMP EQUAL R0 :incrementCurrentWindow
ADD R0 R0 R0
:incrementCNZV

GETPSW R1 0
ADD R2 R1 1		    //Incrementing the CNZV
AND R2 R2 #F
AND R1 R1 #FFFFFFF0
OR R1 R1 R2
PUTPSW R0 R1 0
JMP ALWAYS 4
ADD R0 R0 R0

:incrementSavedWindow
GETPSW R1 0
ADD R2 R1 #10	    //Incrementing the Saved Window
AND R2 R2 #70
AND R1 R1 #FFFFFF8F
OR R1 R1 R2
PUTPSW R0 R1 0
JMP ALWAYS 4
ADD R0 R0 R0

:incrementCurrentWindow
GETPSW R1 0
ADD R2 R1 #80	    //Incrementing the current Window
AND R2 R2 #380
AND R1 R1 #FFFFFC7F
OR R1 R1 R2
PUTPSW R0 R1 0
JMP ALWAYS 4
ADD R0 R0 R0

.word option #00000001