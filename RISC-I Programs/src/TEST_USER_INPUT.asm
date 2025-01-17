JMP ALWAYS R0 :start
ADD R0 R0 R0
.word InputAddress #1000000
:start
LDW R1 R0 .InputAddress
:InputCapture
LDW R3 R1 0					//loads the input into the register 3 
AND R0 R3 128				//tests if there is any input in the buffer
JMP NOT_EQUAL R0 :InputCapture	//if the 8th bit has 1, it means that there is no input
ADD R0 R0 R0
ADD R2 R2 4					//increments the writing address
STW R3 R2 :SavingAdressStart //stores the input into the memory
JMP ALWAYS R0 :InputCapture
ADD R0 R0 R0
:SavingAdressStart