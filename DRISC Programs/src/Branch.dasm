NOP
LUI x20 0xFFFFFFFF
LUI x21 0xF

ADDI x1 x1 0xffffffff
ADDI x2 x2 0xffffffff
ADDI x3 x3 0xffffffff
ADDI x4 x5 0xffffffff
ADDI x5 x5 0xffffffff
ADDI x6 x6 0xffffffff

BEQ x0 x0 :label1
NOP
ANDI x1 x1 0
:label1
BNE x0 x20 :label2
NOP
ANDI x2 x2 0
:label2
BLT x0 x21 :label3
NOP
ANDI x3 x3 0
:label3
BLTU x0 x20 :label4
NOP
ANDI x4 x4 0
:label4
BGE x0 x0 :label5
NOP
ANDI x5 x5 0
:label5
BGEU x20 x0 :label6
NOP
ANDI x6 x6 0
:label6
//jump should not be taken bellow
BEQ x0 x20 :label7
NOP
ADDI x7 x7 0xffffffff
:label7
BNE x0 x0 :label8
NOP
ADDI x8 x8 0xffffffff
:label8
BLT x21 x0 :label9
NOP
ADDI x9 x9 0xffffffff
:label9
BLTU x20 x0 :label10
NOP
ADDI x10 x10 0xffffffff
:label10
BGE x0 x21 :label11
NOP
ADDI x11 x11 0xffffffff
:label11
BGEU x0 x20 :label12
NOP
ADDI x12 x12 0xffffffff
:label12
BEQ x0 x0 :label12
NOP
