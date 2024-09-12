ADD @0 @0 @0
:start
LDHI @1 1
:counter1Start
SUB @1 @1 256
JMP NOT_EQUAL @0 :counter1Start
ADD @0 @0 @0
LDHI @3 2
:counter2Start
SUB @3 @3 512
JMP NOT_EQUAL @0 :counter2Start
ADD @0 @0 @0
JMP ALWAYS @zero :start
ADD @0 @0 @0