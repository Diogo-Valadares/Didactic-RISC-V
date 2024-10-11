//This code is for testing the various Load and Save instructions;
//Each word size and saved in the sequence of addresses after the code;
//In each load, a different register in the local window is used 
//so that signed loads can be checked, since there is no signed save.
//
//in the end there is a final test for the compiler to test if it can
//Clamp the Load High instruction properly. If so the value will be 
//clamped to 19 bits and won't break the program.

ADD R1 R0 :end	//Counter to write each answer in a different address
ADD R2 R0 .var	//save the var address to reg 2

JMP ALWAYS R0 :start
ADD R0 R0 R0

.word var #FAFBFCFD

:start
LDW R16 R2 0 //Full word load and save
STW R16 R1 0
ADD R1 R1 4 //Increment next answer address

LDSU R17 R2 0 //Load unsigned short and save short, 0 offset - 00XX
STS R17 R1 0
ADD R1 R1 4 //next answer address
LDSU R18 R2 1 //offset by 1 byte - 0XX0
STS R18 R1 1
ADD R1 R1 4 //next answer address
LDSU R19 R2 2 //offset by 2 bytes - XX00
STS R19 R1 2
ADD R1 R1 4 //next answer address

LDSS R20 R2 0 //signed and offset by 0 byte - 00XX
STS R20 R1 0
ADD R1 R1 4 //next answer address
LDSS R21 R2 1 //signed and offset by 1 byte - 0XX0
STS R21 R1 1
ADD R1 R1 4 //next answer address
LDSS R22 R2 2 //signed and offset by 2 bytes - XX00
STS R22 R1 2
ADD R1 R1 4 //next answer address


LDBU R23 R2 0 //Load unsigned byte and save byte, 0 offset - 000X
STB R23 R1 0
ADD R1 R1 4 //next answer address
LDBU R24 R2 1 //offset by 1 byte - 00X0
STB R24 R1 1
ADD R1 R1 4 //next answer address
LDBU R25 R2 2 //offset by 2 bytes - 0X00
STB R25 R1 2
ADD R1 R1 4 //next answer address
LDBU R26 R2 3 //offset by 3 bytes - X000
STB R26 R1 3
ADD R1 R1 4 //next answer address

LDBS R27 R2 0 //signed and offset by 0 byte - 000X
STB R27 R1 0
ADD R1 R1 4 //signed and next answer address
LDBS R28 R2 1 //offset by 1 byte - 00X0
STB R28 R1 1
ADD R1 R1 4 //signed and next answer address
LDBS R29 R2 2 //offset by 2 bytes - 0X00
STB R29 R1 2
ADD R1 R1 4 //signed and next answer address
LDBS R30 R2 3 //offset by 2 bytes - X000
STB R30 R1 3

LDHI R31 #FFFFFFFF

:infiniteLoop
JMP ALWAYS R0 :infiniteLoop
ADD R0 R0 R0

:end