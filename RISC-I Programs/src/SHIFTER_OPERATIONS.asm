//Shifter operations test;
//this code should load a value in high which will appear like #..20..
//then this will be shifted to the right by 2 turning it into a #..08..
//this will allow the right arithmetic shift to be tested after this 8 
//is left shifted to the last bits of the register.

ADD R0 R0 R0
LDHI R1 1
SRL R1 R1 2
SLL R1 R1 4
SLL R1 R1 4
SLL R1 R1 4
SLL R1 R1 4
SLL R1 R1 4
SRA R1 R1 4
SRA R1 R1 4
SRL R1 R1 4
SRL R1 R1 4
SRL R1 R1 4
JMP ALWAYS Rzero 1
ADD R0 R0 R0