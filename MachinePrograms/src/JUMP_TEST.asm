//this code should test all jump conditions and store them in the registers starting from 1
//each register represents one condition, and each byte represents a particular test
//for most tests, the register starts being set to #FFFFFFFF and if one of the tests fail, the byte related to it
//is set to #AA, otherwise it stays as #FF
//
//the first test byte will always test when the condition should be true, the rest test when it should be false

ADD @0 @0 0 
LDW @30 @0 .var1
LDW @31 @0 .var2
LDW @20 @0 .test1fail
LDW @21 @0 .test2fail
LDW @22 @0 .test3fail
LDW @23 @0 .test4fail

//****************************** ALWAYS *********************************//

ADD @1 @0 #FFFFFFFF // clears ALWAYS test register
JMPR ALWAYS 12
ADD @0 @0 0
ADD @1 @0 #AAAAAAAA	// Always test failed

//****************************** EQUAL and NOT EQUAL *********************************//

ADD @2 @0 #FFFFFFFF // clears EQUAL and NOT EQUAL test register
SUB @0 @0 0
JMPR EQUAL 12
ADD @0 @0 0
AND @2 @2 @20		// 1° test failed, it can't detect equality

SUB @0 @0 1
JMPR EQUAL 12		// 0 == 1, it shouldn't jump
ADD @0 @0 0
JMPR ALWAYS 12		// if the previous jump failed, this one should jump and won't set fail
ADD @0 @0 0
AND @2 @2 @21		// 2° test failed, it can't detect inequality

SUB @0 @0 1
JMPR NOT_EQUAL 12
ADD @0 @0 0
AND @2 @2 @22		// 1° test failed, it can't detect inequality

SUB @0 @0 0
JMPR NOT_EQUAL 12	// 0 != 0, it shouldn't jump
ADD @0 @0 0
JMPR ALWAYS 12
ADD @0 @0 0
AND @2 @2 @23		// 2° test failed, it can't detect equality

//****************************** GREATER *********************************//

ADD @3 @0 #FFFFFFFF // clears GREATER test register
SUB @0 @31 0		// @31 contains a value greater than 0
JMPR GREATER 12
ADD @0 @0 0
AND @3 @3 @20 // 1° test failed, it can't detect when its greater

SUB @0 @0 0
JMPR GREATER 12		// 0 > 0, it shouldn't jump
ADD @0 @0 0
JMPR ALWAYS 12
ADD @0 @0 0
AND @3 @3 @21 // 2° test failed, it can't detect equality

SUB @0 @0 1
JMPR GREATER 12		// 0 > 1, it shouldn't jump
ADD @0 @0 0	
JMPR ALWAYS 12	
ADD @0 @0 0
AND @3 @3 @22 // 3° test failed, it can't detect when its lesser

//****************************** GREATER OR EQUAL *********************************//

ADD @4 @0 #FFFFFFFF // clears GREATER OR EQUAL test register
SUB @0 @31 0		// @31 contains a value greater than 0
JMPR GREATER_EQUAL 12
ADD @0 @0 0
AND @4 @4 @20 // 1° test failed, it can't detect when its greater

SUB @0 @0 0
JMPR GREATER_EQUAL 12		// 0 >= 0, it should jump too
ADD @0 @0 0
AND @4 @4 @21 // 2° test failed, it can't detect equality

SUB @0 @0 1
JMPR GREATER_EQUAL 12		// 0 >= 1, it shouldn't jump
ADD @0 @0 0	
JMPR ALWAYS 12	
ADD @0 @0 0
AND @4 @4 @22 // 3° test failed, it can't detect when its lesser


//****************************** LESS *********************************//

ADD @5 @0 #FFFFFFFF // clears LESS test register
SUB @0 @0 1			// 0 < 1
JMPR LESS 12
ADD @0 @0 0
AND @5 @5 @20 // 1° Equals test failed, it can't detect when its lesser

SUB @0 @0 0
JMPR LESS 12		// 0 < 0, it shouldn't jump
ADD @0 @0 0
JMPR ALWAYS 12
ADD @0 @0 0
AND @5 @5 @21 // 2° test failed, it can't detect equality

SUB @0 @31 0		// @31 contains a value greater than 0
JMPR LESS 12		// @31 < 0, it shouldn't jump
ADD @0 @0 0	
JMPR ALWAYS 12	
ADD @0 @0 0
AND @5 @5 @22 // 3° test failed, it can't detect when its greater


//****************************** LESS OR EQUAL *********************************//

ADD @6 @0 #FFFFFFFF // clears LESS EQUAL test register
SUB @0 @0 1			// 0 < 1
JMPR LESS_EQUAL 12
ADD @0 @0 0
AND @6 @6 @20 // 1° test failed, it can't detect when its lesser

SUB @0 @0 0
JMPR LESS_EQUAL 12	// 0 <= 0, it should jump too
ADD @0 @0 0
AND @6 @6 @21 // 2° test failed, it can't detect equality

SUB @0 @31 0		// @31 contains a value greater than 0
JMPR LESS_EQUAL 12	// @31 <= 0, it shouldn't jump
ADD @0 @0 0	
JMPR ALWAYS 12	
ADD @0 @0 0
AND @6 @6 @22 // 3° test failed, it can't detect when its greater

//****************************** POSITIVE and NEGATIVE *********************************//

ADD @7 @0 #FFFFFFFF // clears POSITIVE AND NEGATIVE test register
ADD @0 @0 10		// 0 + 10 = 10 is positive
JMPR POSITIVE 12
ADD @0 @0 0
AND @7 @7 @20 // 1° test failed, it can't detect positive numbers

SUB @0 @0 10		// 0 - 10 = -10 is negative
JMPR POSITIVE 12	
ADD @0 @0 0
JMPR ALWAYS 12		// if the previous jump failed, this one should jump and won't set fail
ADD @0 @0 0
AND @7 @7 @21 // 2° test failed, it can't detect inequality

SUB @0 @0 10		// 0 - 10 = -10 is negative
JMPR NEGATIVE 12
ADD @0 @0 0
AND @7 @7 @22 // 1° test failed, it can't detect positive numbers

ADD @0 @0 10		// 0 + 10 = 10 is positive
JMPR NEGATIVE 12	
ADD @0 @0 0
JMPR ALWAYS 12		// if the previous jump failed, this one should jump and won't set fail
ADD @0 @0 0
AND @7 @7 @23 // 2° test failed, it can't detect inequality

//****************************** CARRY *********************************//

ADD @8 @0 #FFFFFFFF // clears CARRY test register
ADD @0 @30 1		// #FFFFFFFF + 1 should carry 1
JMPR CARRY_SET 12
ADD @0 @0 0
AND @8 @8 @20 // 1° test failed, it can't detect when it carries

ADD @0 @0 0			// 0 + 0 shouldn't carry
JMPR CARRY_SET 12
ADD @0 @0 0
JMPR ALWAYS 12
ADD @0 @0 0
AND @8 @8 @21 // 2° test failed, it can't detect when it doesn't carry

ADD @0 @0 @0		// 0 + 0 shouldn't carry
JMPR CARRY_CLEAR 12
ADD @0 @0 0
AND @8 @8 @22 // 1° test failed, it can't detect when the carry is clear

ADD @0 @30 1		// #FFFFFFFF + 1 should carry 1
JMPR CARRY_CLEAR 12
ADD @0 @0 0
JMPR ALWAYS 12
ADD @0 @0 0
AND @8 @8 @23 // 2° test failed, it can't detect when the carry is not clear

//***************************** OVERFLOW ********************************//

ADD @9 @0 #FFFFFFFF // clears OVERFLOW test register
ADD @29 @0 1
SLL @29 @29 31		// @29 = 0x80000000, the lowest value possible, if we subtract 1, it should underflow

SUB @29 @29 1
JMPR OVERFLOW_SET 12
ADD @0 @0 0
AND @9 @9 @20 // 1° test failed, it can't detect when it underflows when subtracting

ADD @29 @29 1
JMPR OVERFLOW_SET 12
ADD @0 @0 0
AND @9 @9 @21 // 2° test failed, it can't detect when it overflows when adding

ADD @29 @29 1
JMPR OVERFLOW_SET 12
ADD @0 @0 0
JMPR ALWAYS 12
ADD @0 @0 0
AND @9 @9 @22 // 3° test failed, it can't detect when it doesn't overflow when adding

ADD @29 @29 1
JMPR OVERFLOW_CLEAR 12
ADD @0 @0 0
AND @9 @9 @23 // 2° test failed, it can't detect when it doesn't overflow(using overflow ClEAR)


JMPR ALWAYS 0
ADD @0 @0 0


.word var1 #FFFFFFFF
.word var2 #0FFFFFFF
.word test1fail #FFFFFFAA
.word test2fail #FFFFAAFF
.word test3fail #FFAAFFFF
.word test4fail #AAFFFFFF