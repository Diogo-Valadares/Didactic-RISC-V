//this code contains the routine for register window saving and restoring 
//whenever there is an window number overflow or underflow.
//It starts at a certain address, right now it is set to #80000000.

//calli* R25 R0 R0	//saves the return address in R25 -This is a hardwired instruction, no need to assemble it.-
getlpc* R24 R0 R0	//saves last instruction address in R24
getpsw R23 R0 R0	//saves the processor status word in R23

add R22 R22 1		//Every address starts at #80000000, so we create an offset 
sll R22 R22 31		//removing the need to use relative instructions

ldhi R21 #60000     //sets the address to the lowest saved window address
ldw R20 R21 0       //loads lowest saved window address					

//if the last instruction that was executed was an return execute the underflowRoutine
ldw R19 R25 0
ldhi R18 #40000
sub R19 R19 R18
jmp GREATER R22 :UnderflowRoutine	
add R0 R0 R0

:OverflowRoutine
stw R26 R20 #04 	//storing the input registers of the next window
stw R27 R20 #08
stw R28 R20 #0C
stw R30 R20 #10
stw R29 R20 #14
stw R31 R20 #18
add R27 R20 0		//passes the address offset as an argument
callr R10 R0 4		//goes to the window that is being saved
stw R16 R11 #1C
stw R17 R11 #20
stw R18 R11 #24
stw R19 R11 #28
stw R20 R11 #2C
stw R21 R11 #30
stw R22 R11 #34
stw R23 R11 #38
stw R24 R11 #3C
stw R25 R11 #40
add R10 R10 #34     //makes the return go to the next line instead of the callr instruction
ret R0 R0 R10		//returns to the routine window

add R20 R20 #40		//Incrementing the lowest saved window address
stw R20 R21 0

add R20 R23 #10	    //Incrementing the Saved Window, but also incrementing the current window
and R20 R20 #70     //so that when we put the PSW, the window does not change
add R21 R23 #80   
and R21 R21 #380 
and R23 R23 #FFFFFC0F
or R23 R23 R20
or R23 R23 R21

putpsw R0 R23 R0	//restore the PSW
jmp* ALWAYS R25 R0
reti* ALWAYS R24 R0


:UnderflowRoutine

add R31 R15 0		//transfer the arguments that are being passed so 
add R30 R14 0		//we can use this space for the next operations
add R29 R13 0
add R28 R12 0
add R27 R11 0
add R26 R10 0

ret R0 R0 R16	//returns to the window calling the return

//The following steps transfer the information that is needed to be restored
//after this routine into the previous windows that is available.
add R31 R25 0				
add R30 R24 0
add R29 R23 0
add R28 R21 0
add R27 R20 0

call R16 R0 0		//goes back to the previous window that is available
add R25 R15 0
add R24 R14 0
add R23 R13 0
add R21 R12 0
add R20 R11 0
ret R0 R0 R16		//returns to the window being saved
			
//now that the information that will be restored is out of the way, we can
//restore the saved window registers
ldw R25 R27 #40		
ldw R24 R27 #3C
ldw R23 R27 #38
ldw R22 R27 #34
ldw R21 R27 #30
ldw R20 R27 #2C
ldw R19 R27 #28
ldw R18 R27 #24
ldw R17 R27 #20
ldw R16 R27 #1C
ldw R15 R27 #18		
ldw R14 R27 #14
ldw R13 R27 #10
ldw R12 R27 #0C
ldw R11 R27 #08
ldw R10 R27 #04

call R22 R0 0		//goes back to the previous window that is available

add R15 R31 0		//restore the arguments that were being passed to the lower window
add R14 R30 0		
add R13 R29 0
add R12 R28 0
add R11 R27 0
add R10 R26 0


sub R20 R20 #40		//Decrementing the lowest saved window address
stw R20 R21 0

sub R23 R23 #10		//decrements the saved window pointer by one

add R31 R25 0		
add R30 R24 0
add R29 R23 0		//lastly we call so the reti instruction goes to the window we were originally 
call R25 R0 R0		//in before the return that triggered this instruction.
					
putpsw R0 R13 R0
jmp* ALWAYS R15 R0	
reti* ALWAYS R14 R0


//.word lowestSavedWindowAddress #40000000
