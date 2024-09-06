JMP ALWAYS @0 :start
ADD @0 @0 @0
.word InputAddress #1000000
:start
LDW @1 @0 .InputAddress
:InputCapture
LDW @3 @1 0					//loads the input into the register 3 
AND @0 @3 128				//tests if there is any input in the buffer
JMP NOT_EQUAL @0 :InputCapture	//if the 8th bit has 1, it means that there is no input
ADD @0 @0 @0
ADD @2 @2 4					//increments the writing address
STW @3 @2 :SavingAdressStart //stores the input into the memory
JMP ALWAYS @0 :InputCapture
ADD @0 @0 @0
:SavingAdressStart