//This is a test for the ALU component.
//It will test every alu operation and save the results on the 
//Register file local window.

ADD @0 @0 @0
LDW @1 @0 .var1
LDW @2 @0 .var2
LDW @3 @0 .one

:start
AND @16 @1 @2	//Should Result in #AAAAAAAA
OR @17 @2 0		//Should Result in #AAAAAAAA
XOR @18 @1 @2	//Should Result in #55555555
ADD @19 @1 1	//Should Result in #00000000 and carry out 1
ADDC @20 @2 0	//Should Result in #AAAAAAAB
SUB @21 @0 1	//Should Result in #FFFFFFFF and carry out 1
SUBC @22 @0 0	//Should Result in #FFFFFFFF
SUBR @23 @3 @0	//Should Result in #FFFFFFFF and carry out 1
SUBCR @24 @0 2	//Should Result in #00000001

JMP ALWAYS @0 :start
ADD @0 @0 @0

.word var1 #FFFFFFFF
.word var2 #AAAAAAAA
.word one 1
