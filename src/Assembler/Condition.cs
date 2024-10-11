namespace RiscAssembler;
#pragma warning disable CA1069
public enum Condition
{
    NEVER = 0x0,
    GREATER = 0x1,
    LESS_EQUAL = 0x2,
    GREATER_EQUAL = 0x3,
    LESS = 0x4,
    HIGHER = 0x5,
    LOWER_SAME = 0x6,
    CARRY_CLEAR = 0x7,
    LOWER = 0x7,
    CARRY_SET = 0x8,
    HIGHER_OR_SAME = 0x8,
    POSITIVE = 0x9,
    NEGATIVE = 0xA,
    NOT_EQUAL = 0xB,
    EQUAL = 0xC,
    OVERFLOW_CLEAR = 0xD,
    OVERFLOW_SET = 0xE,
    ALWAYS = 0xF,
    //Short Terms according to katevenis RISC II book
    NEV = 0x0,  //never // does not exist on katevenis definition
    GT = 0x4,   //Greater than
    LE = 0x7,   //less or equal
    GE = 0x5,   //Greater or equal
    LT = 0x6,   //less than
    HI = 0xA,   //higher than
    LOS = 0xB,  //lower or same
    NC = 0xE,   //no carry
    LO = 0xE,   //lower than
    C = 0xF,    //carry
    HIS = 0xF,   //higher or same
    PL = 0x8,   //plus
    MI = 0x9,   //minus
    NE = 0x2,   //not equal
    EQ = 0x3,   //equals
    NV = 0xC,   //no overflow
    V = 0xD,    //overflow
    ALW = 0x0,  //always
}
#pragma warning restore CA1069