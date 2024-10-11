add R0 R0 R0 //NO_OP
call R31 R0 :callTestFunction
add R0 R0 R0 //NO_OP
jmpr always 0
add R0 R0 R0

:callTestFunction
add R1 R1 1

sub R0 R1 10
jmpr equal 12

call R31 R0 :callTestFunction
add R0 R0 R0 //NO_OP

ret R0 R0 R31
add R0 R0 R0 //NO_OP