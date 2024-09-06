//This code is for testing the various Load and Save instructions;
//Each word size and saved in the sequence of addresses after the code;
//In each load, a different register in the local window is used 
//so that signed loads can be checked, since there is no signed save.
//
//in the end there is a final test for the compiler to test if it can
//Clamp the Load High instruction properly. If so the value will be 
//clamped to 19 bits and won't break the program.

ADD @1 @0 :end	//Counter to write each answer in a different address
ADD @2 @0 .var	//save the var address to reg 2

JMP ALWAYS @0 :start
ADD @0 @0 @0

.word var #FAFBFCFD

:start
LDW @16 @2 0 //Full word load and save
STW @16 @1 0
ADD @1 @1 4 //Increment next answer address

LDSU @17 @2 0 //Load unsigned short and save short, 0 offset - 00XX
STS @17 @1 0
ADD @1 @1 4 //next answer address
LDSU @18 @2 1 //offset by 1 byte - 0XX0
STS @18 @1 1
ADD @1 @1 4 //next answer address
LDSU @19 @2 2 //offset by 2 bytes - XX00
STS @19 @1 2
ADD @1 @1 4 //next answer address

LDSS @20 @2 0 //signed and offset by 0 byte - 00XX
STS @20 @1 0
ADD @1 @1 4 //next answer address
LDSS @21 @2 1 //signed and offset by 1 byte - 0XX0
STS @21 @1 1
ADD @1 @1 4 //next answer address
LDSS @22 @2 2 //signed and offset by 2 bytes - XX00
STS @22 @1 2
ADD @1 @1 4 //next answer address


LDBU @23 @2 0 //Load unsigned byte and save byte, 0 offset - 000X
STB @23 @1 0
ADD @1 @1 4 //next answer address
LDBU @24 @2 1 //offset by 1 byte - 00X0
STB @24 @1 1
ADD @1 @1 4 //next answer address
LDBU @25 @2 2 //offset by 2 bytes - 0X00
STB @25 @1 2
ADD @1 @1 4 //next answer address
LDBU @26 @2 3 //offset by 3 bytes - X000
STB @26 @1 3
ADD @1 @1 4 //next answer address

LDBS @27 @2 0 //signed and offset by 0 byte - 000X
STB @27 @1 0
ADD @1 @1 4 //signed and next answer address
LDBS @28 @2 1 //offset by 1 byte - 00X0
STB @28 @1 1
ADD @1 @1 4 //signed and next answer address
LDBS @29 @2 2 //offset by 2 bytes - 0X00
STB @29 @1 2
ADD @1 @1 4 //signed and next answer address
LDBS @30 @2 3 //offset by 2 bytes - X000
STB @30 @1 3

LDHI @31 #FFFFFFFF

:infiniteLoop
JMP ALWAYS @0 :infiniteLoop
ADD @0 @0 @0

:end