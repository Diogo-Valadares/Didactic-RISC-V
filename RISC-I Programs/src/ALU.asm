//This is a test for the ALU component.
//It will test every alu operation and save the results on the 
//Register file local window.

add R0 R0 R0
ldw R1 R0 .var1
ldw R2 R0 .var2
ldw R3 R0 .one

:start
and R16 R1 R2	//Should Result in #AAAAAAAA
or R17 R2 0		//Should Result in #AAAAAAAA
xor R18 R1 R2	//Should Result in #55555555
add R19 R1 1	//Should Result in #00000000 and carry out 1
addc R20 R2 0	//Should Result in #AAAAAAAB
sub R21 R0 1	//Should Result in #FFFFFFFF and carry out 1
subc R22 R0 0	//Should Result in #FFFFFFFF
subr R23 R3 R0	//Should Result in #FFFFFFFF and carry out 1
subcr R24 R0 2	//Should Result in #00000001

jmp ALWAYS R0 :start
add R0 R0 R0

.word var1 #FFFFFFFF
.word var2 #AAAAAAAA
.word one 1
