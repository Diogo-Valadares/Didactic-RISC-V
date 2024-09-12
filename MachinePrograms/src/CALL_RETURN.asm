ADD @0 @0 @0 //NO_OP
ADD @3 @0 127
CALL @31 @zero :callTestFunction
ADD @0 @0 @0 //NO_OP
ADD @1 @zero 63
SUB @1 @1 32

JMPR ALWAYS 0
ADD @0 @0 @0

:callTestFunction
ADD @2 @zero #FF
SUB @2 @2 #0F
RET @0 @0 @31
ADD @0 @0 @0 //NO_OP