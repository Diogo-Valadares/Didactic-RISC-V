namespace RiscAssembler;
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
}