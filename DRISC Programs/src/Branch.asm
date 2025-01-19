NOP
LUI a1 0xFFFFFFFF
LUI a2 0xF

ADDI s0 s0 0xffffffff
ADDI s1 s1 0xffffffff
ADDI s2 s2 0xffffffff
ADDI s3 s3 0xffffffff
ADDI s4 s4 0xffffffff
ADDI s5 s5 0xffffffff

BEQ x0 x0 :label1
NOP
ANDI s0 s0 0
:label1
BNE x0 a1 :label2
NOP
ANDI s1 s1 0
:label2
BLT x0 a2 :label3
NOP
ANDI s2 s2 0
:label3
BLTU x0 a1 :label4
NOP
ANDI s3 s3 0
:label4
BGE x0 x0 :label5
NOP
ANDI s4 s4 0
:label5
BGEU a1 x0 :label6
NOP
ANDI s5 s5 0
:label6
BEQ x0 x0 :label6
NOP