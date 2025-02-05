NOP

LUI sp 0x1 				// stack pointer <= 0x00001000

ADDI t0 zero 10 
ADDI t0 t0 123

MV a0 t0
MUL a1 t0 t0

ADDI sp sp 4		 	//stack pointer ++
CALL :myProcedure

ADD s2 a1 zero
ADD s3 a2 zero

J 0
NOP

:myProcedure
DIV s0 a1 a0 
ADD a0 a1 a0
ADDI sp sp -4		 	//stack pointer --
RET
NOP


