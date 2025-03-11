namespace DRiscAssembler;
public enum Instructions
{
    load = 0x03,
    load_fp = 0x07,

    op_imm = 0x13,
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
public enum SystemFunct20
{
    ecall = 0x00000,
    ebreak = 0x00100,
    wfi = 0x10500,
    mret = 0x30200,

    csrrw = 0x1,
    csrrs = 0x2,
    csrrc = 0x3,
    csrrwi = 0x5,
    csrrsi = 0x6,
    csrrci = 0x7,
}
public enum CSR
{
    mvendor = 0xf11,
    marchid = 0xf12,
    mimpid = 0xf13,
    mhartid = 0xf14,

    mstatus = 0x300,
    misa = 0x301,
    mie = 0x304,
    mtvec = 0x305,
    mstatush = 0x310,

    mscratch = 0x340,
    mepc = 0x341,
    mcause = 0x342,
    mtval = 0x343,
    mip = 0x344,

    fflags = 0x001,
    frm = 0x002,
    fcsr = 0x003,
    
    cycle = 0xc00,
    time = 0xc01,
    instret = 0xc02,
    cycleh = 0xc80,
    timeh = 0xc81,
    instreth = 0xc82
}


public sealed class EnumConverter(uint value)
{
    public uint value = value;

    public static implicit operator uint(EnumConverter instruction)
    {
        return instruction.value;
    }
    public static implicit operator int(EnumConverter instruction)
    {
        return (int)instruction.value;
    }
    public static implicit operator Register(EnumConverter instruction)
    {
        return (Register)instruction.value;
    }
    public static implicit operator CSR(EnumConverter instruction)
    {
        return (CSR)instruction.value;
    }
    public static implicit operator EnumConverter(Instructions instruction)
    {
        return new EnumConverter((uint)instruction);
    }
    public static implicit operator EnumConverter(DataSize dataSize)
    {
        return new EnumConverter((uint)dataSize);
    }
    public static implicit operator EnumConverter(Operation operation)
    {
        return new EnumConverter((uint)operation);
    }
    public static implicit operator EnumConverter(Branch branch)
    {
        return new EnumConverter((uint)branch);
    }
    public static implicit operator EnumConverter(Register register)
    {
        return new EnumConverter((uint)register);
    }
    public static implicit operator EnumConverter(CSR register)
    {
        return new EnumConverter((uint)register);
    }
    public static implicit operator EnumConverter(SystemFunct20 systemFunct20)
    {
        return new EnumConverter((uint)systemFunct20);
    }
    public static implicit operator EnumConverter(int integer) {
        return new EnumConverter((uint)integer);
    }
    public static implicit operator EnumConverter(uint integer)
    {
        return new EnumConverter(integer);
    }
}