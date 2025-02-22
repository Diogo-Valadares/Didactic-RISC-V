//This code is for testing the various Load and Save instructions;
//Each word size and saved in the sequence of addresses after the code;
//In each load, a different register in the local window is used 
//so that signed loads can be checked, since there is no signed save.
//
//in the end there is a final test for the compiler to test if it can
//Clamp the Load High instruction properly. If so the value will be 
//clamped to 19 bits and won't break the program.
NOP
ADDI x1 zero .var
LW x16 x1 0  
LH x17 x1 0  
LH x18 x1 1  
LH x19 x1 2 
LHU x20 x1 0 
LHU x21 x1 1 
LHU x22 x1 2 
LB x23 x1 0  
LB x24 x1 1  
LB x25 x1 2  
LB x26 x1 3  
LBU x27 x1 0  
LBU x28 x1 1  
LBU x29 x1 2  
LBU x30 x1 3  

JUMP 0
NOP
.word var 0xFAFBFCFD

