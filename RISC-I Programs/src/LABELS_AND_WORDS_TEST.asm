JMP ALWAYS R0 :labeltest
ADD R0 R0 R0
ADD R1 R0 10
.word teste 269488144
.word teste2 4294967295
:labeltest
ADD R2 .teste .teste2
:infiniteLoop
JMP ALWAYS R0 :infiniteLoop
ADD R0 R0 R0