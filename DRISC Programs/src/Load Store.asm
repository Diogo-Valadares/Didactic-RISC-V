//This code is for testing the various Load and Save instructions;
//Each word size and saved in the sequence of addresses after the code;
//In each load, a different register in the local window is used 
//so that signed loads can be checked, since there is no signed save.
//
//in the end there is a final test for the compiler to test if it can
//Clamp the Load High instruction properly. If so the value will be 
//clamped to 19 bits and won't break the program.
NOP

ADDI x1 x0 :end	//Counter to write each answer in a different address
ADDI x2 x0 .var	//save the var address to reg 2

LW x16 x2 0 //Full word load and save
SW x16 x1 0

LHU x17 x2 0 //Load unsigned short and save short, 0 offset - 00XX
SH x17 x1 4
LHU x18 x2 1 //offset by 1 byte - 0XX0
SH x18 x1 9
LHU x19 x2 2 //offset by 2 bytes - XX00
SH x19 x1 14

LH x20 x2 0 //signed and offset by 0 byte - 00XX
SH x20 x1 16
LH x21 x2 1 //signed and offset by 1 byte - 0XX0
SH x21 x1 21
LH x22 x2 2 //signed and offset by 2 bytes - XX00
SH x22 x1 26

LBU x23 x2 0 //Load unsigned byte and save byte, 0 offset - 000X
SB x23 x1 28
LBU x24 x2 1 //offset by 1 byte - 00X0
SB x24 x1 33
LBU x25 x2 2 //offset by 2 bytes - 0X00
SB x25 x1 38
LBU x26 x2 3 //offset by 3 bytes - X000
SB x26 x1 43

LB x27 x2 0 //signed and offset by 0 byte - 000X
SB x27 x1 44
LB x28 x2 1 //offset by 1 byte - 00X0
SB x28 x1 49
LB x29 x2 2 //offset by 2 bytes - 0X00
SB x29 x1 54
LB x30 x2 3 //offset by 2 bytes - X000
SB x30 x1 59

LUI x31 0xFFFFFFFF

JUMP 0
NOP
.word var 0xFAFBFCFD
:end
