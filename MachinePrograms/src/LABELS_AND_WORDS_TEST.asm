JMP ALWAYS @0 :labeltest
ADD @0 @0 @0
ADD @1 @0 10
.word teste 269488144
.word teste2 4294967295
:labeltest
ADD @2 .teste .teste2
:infiniteLoop
JMP ALWAYS @0 :infiniteLoop
ADD @0 @0 @0