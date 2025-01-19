NOP
LUI x1 0xffff			//0x0ffff000
ADDI x1 x1 0x7ff		//0x0ffff7ff
ADDI x1 x1 0x001		//0x0ffff800
ADDI x1 x1 0x7ff		//0x0fffffff

ADDI x2 x0 63			//0x0000003f
SLLI x3 x1 4			//0xfffffff0
SLTI x4 x0 1			//0x00000001
SLTIU x5 x0 0xffffffff	//0x00000001
XORI x6 x0 0xaaa		//0xfffffaaa
SRLI x7 x2 1			//0x0000001f
SRAI x8 x3 4			//0xffffffff -
ORI x9 x0 0xfff			//0xffffffff
ANDI x10 x1 0xf			//0x0000000f

ADD x11 x0 x2			//0x0000003f
SUB x12 x1 x2			//0x0fffffC0
SLL x13 x1 x4			//0x1ffffffe 
SLT x14 x0 x1			//0x00000001
SLTU x15 x0 x9 			//0x00000001
XOR x16 x0 x1			//0x0fffffff
SRL x17 x1 x4			//0x07ffffff
SRA x18 x6 x4			//0xfffffd55 
OR x19 x12 x4			//0x0fffffC1
AND x20 x1 x4			//0x00000001


MUL x21 x2 x2			//0x00000f81
MULH x22 x3 x3			//0x00000000 
MULHSU x23 x3 x3		//0x00000000?check implementation
MULHU x24 x1 x3			//0x0ffffffe
DIV x25 x1 x2			//0x00410410
DIVU x26 x8 x2			//0x04104104
REM x27 x8 x2			//0xffffffff
REMU x28 x8 x2			//0x00000003

LUI x29 1
LUI x30 2
LUI x31 3
JUMP 0
NOP
