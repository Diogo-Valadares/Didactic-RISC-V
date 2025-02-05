nop
jump :firstJump
addi x1 zero 0xfff //shouldn't happen
:firstJump
ja :secondJump
addi x2 zero 0xfff //shouldn't happen
:secondJump
beq x0 x0 :thirdJump
addi x3 zero 0xfff //shouldn't happen
:thirdJump
lw x4 zero .var
addi x5 x4 0 //should result in 0xffffffff
jump 0
nop

.word var 0xffffffff
