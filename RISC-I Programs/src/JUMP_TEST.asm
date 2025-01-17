//this code should test all jump conditions and store them in the registers starting from 1
//each register represents one condition, and each byte represents a particular test
//for most tests, the register starts being set to #FFFFFFFF and if one of the tests fail, the byte related to it
//is set to #AA, otherwise it stays as #FF
//
//the first test byte will always test when the condition should be true, the rest test when it should be false

ADD R0 R0 0 
LDW R30 R0 .var1
LDW R31 R0 .var2
LDW R20 R0 .test1fail
LDW R21 R0 .test2fail
LDW R22 R0 .test3fail
LDW R23 R0 .test4fail

//****************************** ALWAYS *********************************//

ADD R1 R0 #FFFFFFFF // clears ALWAYS test register
JMPR ALWAYS 12
ADD R0 R0 0
ADD R1 R0 #AAAAAAAA	// Always test failed

//****************************** EQUAL and NOT EQUAL *********************************//

ADD R2 R0 #FFFFFFFF // clears EQUAL and NOT EQUAL test register
SUB R0 R0 0
JMPR EQUAL 12
ADD R0 R0 0
AND R2 R2 R20		// 1° test failed, it can't detect equality

SUB R0 R0 1
JMPR EQUAL 12		// 0 == 1, it shouldn't jump
ADD R0 R0 0
JMPR ALWAYS 12		// if the previous jump failed, this one should jump and won't set fail
ADD R0 R0 0
AND R2 R2 R21		// 2° test failed, it can't detect inequality

SUB R0 R0 1
JMPR NOT_EQUAL 12
ADD R0 R0 0
AND R2 R2 R22		// 1° test failed, it can't detect inequality

SUB R0 R0 0
JMPR NOT_EQUAL 12	// 0 != 0, it shouldn't jump
ADD R0 R0 0
JMPR ALWAYS 12
ADD R0 R0 0
AND R2 R2 R23		// 2° test failed, it can't detect equality

//****************************** GREATER *********************************//

ADD R3 R0 #FFFFFFFF // clears GREATER test register
SUB R0 R31 0		// R31 contains a value greater than 0
JMPR GREATER 12
ADD R0 R0 0
AND R3 R3 R20 // 1° test failed, it can't detect when its greater

SUB R0 R0 0
JMPR GREATER 12		// 0 > 0, it shouldn't jump
ADD R0 R0 0
JMPR ALWAYS 12
ADD R0 R0 0
AND R3 R3 R21 // 2° test failed, it can't detect equality

SUB R0 R0 1
JMPR GREATER 12		// 0 > 1, it shouldn't jump
ADD R0 R0 0	
JMPR ALWAYS 12	
ADD R0 R0 0
AND R3 R3 R22 // 3° test failed, it can't detect when its lesser

//****************************** GREATER OR EQUAL *********************************//

ADD R4 R0 #FFFFFFFF // clears GREATER OR EQUAL test register
SUB R0 R31 0		// R31 contains a value greater than 0
JMPR GREATER_EQUAL 12
ADD R0 R0 0
AND R4 R4 R20 // 1° test failed, it can't detect when its greater

SUB R0 R0 0
JMPR GREATER_EQUAL 12		// 0 >= 0, it should jump too
ADD R0 R0 0
AND R4 R4 R21 // 2° test failed, it can't detect equality

SUB R0 R0 1
JMPR GREATER_EQUAL 12		// 0 >= 1, it shouldn't jump
ADD R0 R0 0	
JMPR ALWAYS 12	
ADD R0 R0 0
AND R4 R4 R22 // 3° test failed, it can't detect when its lesser


//****************************** LESS *********************************//

ADD R5 R0 #FFFFFFFF // clears LESS test register
SUB R0 R0 1			// 0 < 1
JMPR LESS 12
ADD R0 R0 0
AND R5 R5 R20 // 1° Equals test failed, it can't detect when its lesser

SUB R0 R0 0
JMPR LESS 12		// 0 < 0, it shouldn't jump
ADD R0 R0 0
JMPR ALWAYS 12
ADD R0 R0 0
AND R5 R5 R21 // 2° test failed, it can't detect equality

SUB R0 R31 0		// R31 contains a value greater than 0
JMPR LESS 12		// R31 < 0, it shouldn't jump
ADD R0 R0 0	
JMPR ALWAYS 12	
ADD R0 R0 0
AND R5 R5 R22 // 3° test failed, it can't detect when its greater


//****************************** LESS OR EQUAL *********************************//

ADD R6 R0 #FFFFFFFF // clears LESS EQUAL test register
SUB R0 R0 1			// 0 < 1
JMPR LESS_EQUAL 12
ADD R0 R0 0
AND R6 R6 R20 // 1° test failed, it can't detect when its lesser

SUB R0 R0 0
JMPR LESS_EQUAL 12	// 0 <= 0, it should jump too
ADD R0 R0 0
AND R6 R6 R21 // 2° test failed, it can't detect equality

SUB R0 R31 0		// R31 contains a value greater than 0
JMPR LESS_EQUAL 12	// R31 <= 0, it shouldn't jump
ADD R0 R0 0	
JMPR ALWAYS 12	
ADD R0 R0 0
AND R6 R6 R22 // 3° test failed, it can't detect when its greater

//****************************** POSITIVE and NEGATIVE *********************************//

ADD R7 R0 #FFFFFFFF // clears POSITIVE AND NEGATIVE test register
ADD R0 R0 10		// 0 + 10 = 10 is positive
JMPR POSITIVE 12
ADD R0 R0 0
AND R7 R7 R20 // 1° test failed, it can't detect positive numbers

SUB R0 R0 10		// 0 - 10 = -10 is negative
JMPR POSITIVE 12	
ADD R0 R0 0
JMPR ALWAYS 12		// if the previous jump failed, this one should jump and won't set fail
ADD R0 R0 0
AND R7 R7 R21 // 2° test failed, it can't detect inequality

SUB R0 R0 10		// 0 - 10 = -10 is negative
JMPR NEGATIVE 12
ADD R0 R0 0
AND R7 R7 R22 // 1° test failed, it can't detect positive numbers

ADD R0 R0 10		// 0 + 10 = 10 is positive
JMPR NEGATIVE 12	
ADD R0 R0 0
JMPR ALWAYS 12		// if the previous jump failed, this one should jump and won't set fail
ADD R0 R0 0
AND R7 R7 R23 // 2° test failed, it can't detect inequality

//****************************** CARRY *********************************//

ADD R8 R0 #FFFFFFFF // clears CARRY test register
ADD R0 R30 1		// #FFFFFFFF + 1 should carry 1
JMPR CARRY_SET 12
ADD R0 R0 0
AND R8 R8 R20 // 1° test failed, it can't detect when it carries

ADD R0 R0 0			// 0 + 0 shouldn't carry
JMPR CARRY_SET 12
ADD R0 R0 0
JMPR ALWAYS 12
ADD R0 R0 0
AND R8 R8 R21 // 2° test failed, it can't detect when it doesn't carry

ADD R0 R0 R0		// 0 + 0 shouldn't carry
JMPR CARRY_CLEAR 12
ADD R0 R0 0
AND R8 R8 R22 // 1° test failed, it can't detect when the carry is clear

ADD R0 R30 1		// #FFFFFFFF + 1 should carry 1
JMPR CARRY_CLEAR 12
ADD R0 R0 0
JMPR ALWAYS 12
ADD R0 R0 0
AND R8 R8 R23 // 2° test failed, it can't detect when the carry is not clear

//***************************** OVERFLOW ********************************//

ADD R9 R0 #FFFFFFFF // clears OVERFLOW test register
ADD R29 R0 1
SLL R29 R29 31		// R29 = 0x80000000, the lowest value possible, if we subtract 1, it should underflow

SUB R29 R29 1
JMPR OVERFLOW_SET 12
ADD R0 R0 0
AND R9 R9 R20 // 1° test failed, it can't detect when it underflows when subtracting

ADD R29 R29 1
JMPR OVERFLOW_SET 12
ADD R0 R0 0
AND R9 R9 R21 // 2° test failed, it can't detect when it overflows when adding

ADD R29 R29 1
JMPR OVERFLOW_SET 12
ADD R0 R0 0
JMPR ALWAYS 12
ADD R0 R0 0
AND R9 R9 R22 // 3° test failed, it can't detect when it doesn't overflow when adding

ADD R29 R29 1
JMPR OVERFLOW_CLEAR 12
ADD R0 R0 0
AND R9 R9 R23 // 2° test failed, it can't detect when it doesn't overflow(using overflow ClEAR)


JMPR ALWAYS 0
ADD R0 R0 0


.word var1 #FFFFFFFF
.word var2 #0FFFFFFF
.word test1fail #FFFFFFAA
.word test2fail #FFFFAAFF
.word test3fail #FFAAFFFF
.word test4fail #AAFFFFFF