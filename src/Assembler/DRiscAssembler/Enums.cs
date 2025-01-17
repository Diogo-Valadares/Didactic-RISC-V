namespace DRiscAssembler;
public enum Instructions
{
    load = 0x03,
    load_fp = 0x07,

    opimm = 0x13,
    auipc = 0x17,

    store = 0x23,
    store_fp = 0x2f,

    op = 0x33,
    lui = 0x37,

    op_fp = 0x53,

    branch = 0x63,
    jalr = 0x67,
    jal = 0x6f,

    system = 0x73,

}
public enum DataSize
{
    @byte = 0x0,
    half = 0x1,
    word = 0x2,
    @float = 0x3,
    ubyte = 0x4,
    uhalf = 0x5,
}
public enum Operation
{
    add = 0x00,
    addi = add,
    sub = 0x100,
    sll = 0x01,
    slli = sll,
    slt = 0x02,
    slti = slt,
    sltu = 0x03,
    sltiu = sltu,
    xor = 0x04,
    xori = xor,
    srl = 0x05,
    srli = srl,
    sra = 0x105,
    srai = sra,
    or = 0x06,
    ori = or,
    and = 0x07,
    andi = and,

    mul = 0x10,
    mulh = 0x11,
    mulhsu = 0x12,
    mulhu = 0x13,
    div = 0x14,
    divu = 0x15,
    rem = 0x16,
    remu = 0x17
}
public enum Branch
{
    beq = 0x00,
    bne = 0x01,
    blt = 0x04,
    bge = 0x05,
    bltu = 0x06,
    bgeu = 0x07
}
public enum Register
{
    x0 = 0x00,
    zero = x0,
    x1 = 0x01,
    ra = x1,
    x2 = 0x02,
    sp = x2,
    x3 = 0x03,
    gp = x3,
    x4 = 0x04,
    tp = x4,
    x5 = 0x05,
    t0 = x5,
    x6 = 0x06,
    t1 = x6,
    x7 = 0x07,
    t2 = x7,
    x8 = 0x08,
    s0 = x8,
    fp = x8,  // Frame pointer alias
    x9 = 0x09,
    s1 = x9,
    x10 = 0x0a,
    a0 = x10,
    x11 = 0x0b,
    a1 = x11,
    x12 = 0x0c,
    a2 = x12,
    x13 = 0x0d,
    a3 = x13,
    x14 = 0x0e,
    a4 = x14,
    x15 = 0x0f,
    a5 = x15,
    x16 = 0x10,
    a6 = x16,
    x17 = 0x11,
    a7 = x17,
    x18 = 0x12,
    s2 = x18,
    x19 = 0x13,
    s3 = x19,
    x20 = 0x14,
    s4 = x20,
    x21 = 0x15,
    s5 = x21,
    x22 = 0x16,
    s6 = x22,
    x23 = 0x17,
    s7 = x23,
    x24 = 0x18,
    s8 = x24,
    x25 = 0x19,
    s9 = x25,
    x26 = 0x1a,
    s10 = x26,
    x27 = 0x1b,
    s11 = x27,
    x28 = 0x1c,
    t3 = x28,
    x29 = 0x1d,
    t4 = x29,
    x30 = 0x1e,
    t5 = x30,
    x31 = 0x1f,
    t6 = x31
}
