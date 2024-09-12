namespace RiscAssembler;
#pragma warning disable CA1069
public enum Condition
{
    ALWAYS = 0x0,
    NEVER = 0x1,
    NOT_EQUAL = 0x2,
    EQUAL = 0x3,
    GREATER = 0x4,
    GREATER_EQUAL = 0x5,
    LESS = 0x6,
    LESS_EQUAL = 0x7,
    POSITIVE = 0x8,
    NEGATIVE = 0x9,
    HIGHER = 0xA,
    LOWER_SAME = 0xB,
    OVERFLOW_CLEAR = 0xC,
    OVERFLOW_SET = 0xD,
    CARRY_CLEAR = 0xE,
    CARRY_SET = 0xF,
    //Short Terms according to katevenis RISC II book
    ALW = 0x0,  //always
    NEV = 0x1,  //never // does not exist on katevenis definition
    NE = 0x2,   //not equak
    EQ = 0x3,   //equals
    GT = 0x4,   //Greater than
    GE = 0x5,   //Greater or equal
    LT = 0x6,   //less than
    LE = 0x7,   //less or equal
    PL = 0x8,   //plus
    MI = 0x9,   //minus
    HI = 0xA,   //higher than
    LOS = 0xB,  //lower or same
    NV = 0xC,   //no overflow
    V = 0xD,    //overflow
    NC = 0xE,   //no carry
    LO = 0xE,   //lower than
    C = 0xF,    //carry
    his = 0xF   //higher or same
}
#pragma warning restore CA1069