//Shifter operations test;
//this code should load a value in high which will appear like #..20..
//then this will be shifted to the right by 2 turning it into a #..08..
//this will allow the right arithmetic shift to be tested after this 8 
//is left shifted to the last bits of the register.

ADD @0 @0 @0
LDHI @1 1
SRL @1 @1 2
SLL @1 @1 4
SLL @1 @1 4
SLL @1 @1 4
SLL @1 @1 4
SLL @1 @1 4
SRA @1 @1 4
SRA @1 @1 4
SRL @1 @1 4
SRL @1 @1 4
SRL @1 @1 4
JMP ALWAYS @zero 1
ADD @0 @0 @0