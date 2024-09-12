JMP ALWAYS @0 :start
ADD @0 @0 @0
.word var #FFFFFFFF
:start
LDRW @1 #FFFFFFFC //load the information present in 4 bytes before the address of this instruction
STRB @1 #00001000 //test if it writes correctly 1000(hex) addresses after the address of this instruction
STRB @1 #00001002
STRS @1 #00001000
STRS @1 #00001001
STRW @1 #00001000

JMPR ALWAYS #10
ADD @0 @0 @0
ADD @2 @2 #FF
ADD @3 @3 #FF
ADD @4 @4 #FF //should be the only add being executed
CALLR @5 #10
ADD @0 @0 @0
ADD @6 @6 #FF
ADD @7 @7 #FF
ADD @8 @8 #FF //should be the only add being executed

JMPR ALWAYS 0 //jumps to itself and creates an infinite loop
ADD @0 @0 @0