NOP
:FirstJump
ADDI x1 x1 1
J :NextJump
ADDI x1 x1 -1
:NextJump
ADDI x2 x2 -1
JA :FirstJump
ADDI x2 x2 1
NOP
