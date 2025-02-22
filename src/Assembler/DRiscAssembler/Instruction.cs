namespace DRiscAssembler;

internal static class Instruction
{
    public static readonly Dictionary<string, Func<string[], uint[]>> instructions = new()
    {
        {"LUI",  (p) => [TranslateU((uint)Instructions.lui, p[0], p[1])]},
        {"LI",   (p) =>
            {
                int immediate = (int)ToInteger(p[1]);
                if(int.Abs(immediate) <= 0x800)
                {
                    return [TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, p[0],"x0",p[1])];
                }
                else if((immediate & 0xfff) != 0)
                {
                    var lui = TranslateU((uint)Instructions.lui, p[0], ((immediate >> 12) +
                        (((int)immediate & 0x800) >> 11)).ToString());
                    Console.Write("\n\t");
                    var addi = TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, p[0],"x0",p[1]);
                    return [lui,addi];
                }
                else
                {
                    return [TranslateU((uint)Instructions.lui, p[0], (immediate >> 12).ToString())];
                }
            }
        },
        {"AUIPC",(p) => [TranslateU((uint)Instructions.auipc, p[0], p[1])]},
        {"J",    (p) => [TranslateJ((uint)Instructions.jal, "x0", p[0])]},
        {"JUMP", (p) => [TranslateJ((uint)Instructions.jal, "x0", p[0])]},
        {"CALL", (p) =>//needs testing
            {
                if(int.Abs((int)ToInteger(p[0])) < 0x200000)
                {
                    return [TranslateJ((uint)Instructions.jal, "ra", p[0])];
                }
                else
                {
                    var auipc = TranslateU((uint)Instructions.auipc, "ra", ((ToInteger(p[0]) >> 12) +
                        (((int)ToInteger(p[0]) & 0x800) >> 11)).ToString());
                    Console.Write("\n\t");
                    var jalr = TranslateI((uint)Instructions.jalr, 0, "ra", "ra", p[0]);
                    return[auipc,jalr];
                }
            }
        },
        {"JAL",  (p) => [TranslateJ((uint)Instructions.jal, p[0], p[1])]},
        {"JALR", (p) => [TranslateI((uint)Instructions.jalr, 0, p[0],p[1],p[2])]},
        {"RET",  (p) => [TranslateI((uint)Instructions.jalr, 0, "x0","ra","0")]},
        {"JA",   (p) => [TranslateI((uint)Instructions.jalr, 0, "x0","x0",p[0])]},
        {"ECALL",(p) => [TranslateI((uint)Instructions.system, 0, "x0", "x0", "0")]},
        {"MV",   (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, p[0],p[1],"0")]},
        {"NOP",  (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, "x0","x0","0")]},        
        //BRANCH
        {"BEQ",  (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.beq, p[0], p[1], p[2])]},
        {"BNE",  (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bne, p[0], p[1], p[2])]},
        {"BLT",  (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.blt, p[0], p[1], p[2])]},
        {"BGT",  (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.blt, p[1], p[0], p[2])]},
        {"BLTU", (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bltu, p[0], p[1], p[2])]},
        {"BGTU", (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bltu, p[1], p[0], p[2])]},
        {"BLE",  (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bge, p[1], p[0], p[2])]},
        {"BGE",  (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bge, p[0], p[1], p[2])]},
        {"BLEU", (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bgeu, p[1], p[0], p[2])]},
        {"BGEU", (p) => [TranslateB((uint)Instructions.branch, (uint)Branch.bgeu, p[0], p[1], p[2])]},
        //LOAD
        {"LB",   (p) => [TranslateI((uint)Instructions.load, (uint)DataSize.@byte, p[0], p[1], p[2])]},
        {"LBU",  (p) => [TranslateI((uint)Instructions.load, (uint)DataSize.ubyte, p[0], p[1], p[2])]},
        {"LH",   (p) => [TranslateI((uint)Instructions.load, (uint)DataSize.half, p[0], p[1], p[2])]},
        {"LHU",  (p) => [TranslateI((uint)Instructions.load, (uint)DataSize.uhalf, p[0], p[1], p[2])]},
        {"LW",   (p) => [TranslateI((uint)Instructions.load, (uint)DataSize.word, p[0], p[1], p[2])]},
        {"LF",   (p) => [TranslateI((uint)Instructions.load, (uint)DataSize.@float, p[0], p[1], p[2])]},
        //STORE
        {"SB",   (p) => [TranslateS((uint)Instructions.store, (uint)DataSize.@byte, p[0], p[1], p[2])]},
        {"SH",   (p) => [TranslateS((uint)Instructions.store, (uint)DataSize.half, p[0], p[1], p[2])]},
        {"SW",   (p) => [TranslateS((uint)Instructions.store, (uint)DataSize.word, p[0], p[1], p[2])]},
        {"SF",   (p) => [TranslateS((uint)Instructions.store, (uint)DataSize.@float, p[0], p[1], p[2])]},
        //ALU-immediate 
        {"ADDI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, p[0],p[1],p[2])]},
        {"INC",  (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, p[0],p[0],p[1])]},
        {"DEC",  (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.addi, p[0],p[0],(-(int)ToInteger(p[1],0xfff)).ToString())]},
        {"SLTI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.slti, p[0],p[1],p[2])]},
        {"SLTIU",(p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.sltiu, p[0],p[1],p[2])]},
        {"SGTI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.slti, p[0],p[2],p[1])]},
        {"SGTIU",(p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.sltiu, p[0],p[2],p[1])]},
        {"SEQZ", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.sltiu, p[0],p[1],"1")]},
        {"XORI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.xori, p[0],p[1],p[2])]},
        {"ORI",  (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.ori, p[0],p[1],p[2])]},
        {"ANDI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.andi, p[0],p[1],p[2])]},
        {"SLLI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.slli, p[0],p[1],p[2])]},
        {"SRLI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.srli, p[0],p[1],p[2])]},
        {"SRAI", (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.srai, p[0],p[1],$"{ToInteger(p[2],0x1F)|0x400}")]},
        //ALU-arithmetic
        {"ADD",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.add, p[0], p[1], p[2])]},
        {"SUB",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.sub, p[0], p[1], p[2])]},
        {"MUL",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.mul, p[0], p[1], p[2])]},
        {"MULH", (p) => [TranslateR((uint)Instructions.op, (uint)Operation.mulh, p[0], p[1], p[2])]},
        {"MULHSU",(p) =>[TranslateR((uint)Instructions.op, (uint)Operation.mulhsu, p[0], p[1], p[2])]},
        {"MULHU",(p) => [TranslateR((uint)Instructions.op, (uint)Operation.mulhu, p[0], p[1], p[2])]},
        {"DIV",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.div, p[0], p[1], p[2])]},
        {"DIVU", (p) => [TranslateR((uint)Instructions.op, (uint)Operation.divu, p[0], p[1], p[2])]},
        {"REM",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.rem, p[0], p[1], p[2])]},
        {"REMU", (p) => [TranslateR((uint)Instructions.op, (uint)Operation.remu, p[0], p[1], p[2])]},
        //ALU-logic
        {"AND",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.and, p[0], p[1], p[2])]},
        {"OR",   (p) => [TranslateR((uint)Instructions.op, (uint)Operation.or, p[0], p[1], p[2])]},
        {"XOR",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.xor, p[0], p[1], p[2])]},
        {"NOT",  (p) => [TranslateI((uint)Instructions.op_imm, (uint)Operation.xori, p[0], p[1], "-1")]},
        //ALU-comparison
        {"SLT",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.slt, p[0], p[1], p[2])]},
        {"SLTU", (p) => [TranslateR((uint)Instructions.op, (uint)Operation.sltu, p[0], p[1], p[2])]},
        {"SGT",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.slt, p[0], p[2], p[1])]},
        {"SGTU", (p) => [TranslateR((uint)Instructions.op, (uint)Operation.sltu, p[0], p[2], p[1])]},
        //SHIFTER
        {"SLL",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.sll, p[0], p[1], p[2])]},
        {"SRL",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.srl, p[0], p[1], p[2])]},
        {"SRA",  (p) => [TranslateR((uint)Instructions.op, (uint)Operation.sra, p[0], p[1], p[2])]}
    };
    /// <summary>
    /// Defines the set of instructions that are PC-relative to calculate the value of the labels.
    /// </summary>
    public static readonly HashSet<string> PCRelativeInstructions =
    [
        "BEQ",
        "BNE",
        "BLT",
        "BGT",
        "BLTU",
        "BGTU",
        "BLE",
        "BGE",
        "BLEU",
        "BGEU",
        "J",
        "JUMP",
        "JAL",
        "CALL"
    ];

    /// <summary>
    /// Translates an R-type instruction to its machine code representation.
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="rd">The destination register.</param>
    /// <param name="rs1">The first source register.</param>
    /// <param name="rs2">The second source register.</param>
    /// <param name="funct10">The function field (funct7 and funct3 combined).</param>
    /// <returns>The machine code representation of the instruction.</returns>
    private static uint TranslateR(uint instruction, uint funct10, string rd, string rs1, string rs2)
    {
        uint result = instruction;

        result |= TryParseRegister(rd) << 7;

        result |= (funct10 & 0x7) << 12;

        result |= TryParseRegister(rs1) << 15;

        result |= TryParseRegister(rs2) << 20;

        result |= (funct10 & ~(uint)0x7) << 22;

        #region print
        var resBin = ToBinary(result);
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write(resBin[0..7]);
        Console.ForegroundColor = ConsoleColor.DarkCyan;
        Console.Write(resBin[7..12]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[12..17]);
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write(resBin[17..20]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[20..25]);
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write(resBin[25..]);
        Console.ForegroundColor = ConsoleColor.White;
        #endregion

        return result;
    }
    /// <summary>
    /// Translates an I-type instruction to its machine code representation.
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="rd">The destination register.</param>
    /// <param name="funct3">The function field (funct3).</param>
    /// <param name="rs1">The source register.</param>
    /// <param name="imm12">The 12-bit immediate value.</param>
    /// <returns>The machine code representation of the instruction.</returns>
    private static uint TranslateI(uint instruction, uint funct3, string rd, string rs1, string imm12)
    {
        uint result = instruction;

        result |= TryParseRegister(rd) << 7;

        result |= (funct3 & 0x7) << 12;

        result |= TryParseRegister(rs1) << 15;

        result |= ToInteger(imm12, 0xFFF) << 20;

        #region print
        var resBin = ToBinary(result);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[0..12]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[12..17]);
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write(resBin[17..20]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[20..25]);
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write(resBin[25..]);
        Console.ForegroundColor = ConsoleColor.White;
        #endregion

        return result;
    }
    /// <summary>
    /// Translates an S-type instruction to its machine code representation.
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="rs1">The source register.</param>
    /// <param name="rs2">The base register.</param>
    /// <param name="funct3">The function field (funct3).</param>
    /// <param name="imm12">The 12-bit immediate value.</param>
    /// <returns>The machine code representation of the instruction.</returns>
    private static uint TranslateS(uint instruction, uint funct3, string rs2, string rs1, string imm12)
    {
        uint result = instruction;
        uint immediate = ToInteger(imm12, 0xFFF);

        result |= (immediate & 0x1F) << 7;
        result |= (funct3 & 0x7) << 12;

        result |= TryParseRegister(rs1) << 15;

        result |= TryParseRegister(rs2) << 20;

        result |= (immediate & ~(uint)0x1F) << 20;

        #region print
        var resBin = ToBinary(result);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[0..7]);
        Console.ForegroundColor = ConsoleColor.DarkCyan;
        Console.Write(resBin[7..12]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[12..17]);
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write(resBin[17..20]);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[20..25]);
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write(resBin[25..]);
        Console.ForegroundColor = ConsoleColor.White;
        #endregion

        return result;
    }
    /// <summary>
    /// Translates a B-type instruction to its machine code representation.
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="rs1">The source register.</param>
    /// <param name="rs2">The target register.</param>
    /// <param name="funct3">The function field (funct3).</param>
    /// <param name="imm12">The 12-bit immediate value.</param>
    /// <returns>The machine code representation of the instruction.</returns>
    private static uint TranslateB(uint instruction, uint funct3, string rs1, string rs2, string imm12)
    {
        uint result = instruction;
        uint immediate = ToInteger(imm12, 0x1FFF);

        result |= (immediate & 0x800) >> 4;
        result |= (immediate & 0x1E) << 7;
        result |= (funct3 & 0x7) << 12;

        result |= TryParseRegister(rs1) << 15;

        result |= TryParseRegister(rs2) << 20;

        result |= (immediate & 0x7E0) << 20;
        result |= (immediate & 0x1000) << 19;

        #region print
        var resBin = ToBinary(result);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[0..7]);
        Console.ForegroundColor = ConsoleColor.DarkCyan;
        Console.Write(resBin[7..12]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[12..17]);
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write(resBin[17..20]);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[20..25]);
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write(resBin[25..]);
        Console.ForegroundColor = ConsoleColor.White;
        #endregion

        return result;
    }
    /// <summary>
    /// Translates a U-type instruction to its machine code representation.
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="rd">The destination register.</param>
    /// <param name="imm20">The 20-bit immediate value.</param>
    /// <returns>The machine code representation of the instruction.</returns>
    private static uint TranslateU(uint instruction, string rd, string imm20)
    {
        uint result = instruction;

        result |= TryParseRegister(rd) << 7;

        result |= ToInteger(imm20, 0xFFFFF) << 12;

        #region print
        var resBin = ToBinary(result);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[0..20]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[20..25]);
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write(resBin[25..]);
        Console.ForegroundColor = ConsoleColor.White;
        #endregion

        return result;
    }
    /// <summary>
    /// Translates a J-type instruction to its machine code representation.
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="rd">The destination register.</param>
    /// <param name="imm20">The 20-bit immediate value.</param>
    /// <returns>The machine code representation of the instruction.</returns>
    private static uint TranslateJ(uint instruction, string rd, string imm20)
    {
        uint result = instruction;

        result |= TryParseRegister(rd) << 7;

        uint imm = ToInteger(imm20, 0x1FFFFF) >> 1;
        result |= (imm & 0x7F800) << 1 | (imm & 0x400) << 10 | (imm & 0x3FF) << 21 | (imm & 0x80000) << 12;

        #region print
        var resBin = ToBinary(result);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(resBin[0..20]);
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write(resBin[20..25]);
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write(resBin[25..]);
        Console.ForegroundColor = ConsoleColor.White;
        #endregion

        return result;
    }

    /// <summary>
    /// Translates a string number to an integer.
    /// </summary>
    /// <param name="number"></param>
    /// <returns></returns>
    public static uint ToInteger(string number, uint mask = 0xffffffff)
    {
        if (number.StartsWith("0x"))
        {
            return (uint)int.Parse(number[2..], System.Globalization.NumberStyles.AllowHexSpecifier) & mask;
        }
        return (uint)int.Parse(number, System.Globalization.NumberStyles.Integer) & mask;
    }
    
    public static uint TryParseRegister(string register)
    {
        if (int.TryParse(register, out var _))
        {
            throw new ArgumentException($"Register not valid: \"{register}\"(Did you mean to use an immediate intruction?).");
        }
        if (Enum.TryParse(typeof(Register), register, true, out var reg))
        {
            return (uint)(int)reg;
        }
        throw new ArgumentException($"Register not valid: \"{register}\".");
    }

    public static string ToBinary(uint value) => Convert.ToString(value, 2).PadLeft(32, '0');
}