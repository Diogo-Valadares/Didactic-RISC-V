using System.Diagnostics;

namespace DRiscAssembler;

internal static class Instruction
{
    public static bool IsPositionIndependentCode { get; set; } = false;
    /// <summary>
    /// Provides an function that will return an array of translating functions for each instruction.
    /// </summary>
    /// PseudoInstructions have been commented to make them easier to track.
    public static readonly Dictionary<string, Func<string[], Func<uint>[]>> instructions = new()
    {
        {"LUI",   (p) => [() => TranslateU(Instructions.lui, p[0], p[1])]},
        {"AUIPC", (p) => [() => TranslateU(Instructions.auipc, p[0], p[1])]},
        {"J",     (p) => [() => TranslateJ(Instructions.jal, "x0", p[0])]},//jump (to pc+imm)
        {"JUMP",  (p) => [() => TranslateJ(Instructions.jal, "x0", p[0])]},//same as above
        {"JR",    (p) => [() => TranslateI(Instructions.jalr, 0, "x0", p[0], "0")]},//Jump (to) Register
        {"JAL",   (p) => [() => TranslateJ(Instructions.jal, p[0], p[1])]},
        {"JALR",  (p) => [() => TranslateI(Instructions.jalr, 0, p[0], p[1], p[2])]},
        {"RET",   (p) => [() => TranslateI(Instructions.jalr, 0, "x0", "ra", "0")]},//return
        {"MV",    (p) => [() => TranslateI(Instructions.op_imm, Operation.addi, p[0], p[1], "0")]},//Move 
        {"NOP",   (p) => [() => TranslateI(Instructions.op_imm, Operation.addi, "x0", "x0", "0")]},//No Operations      
        //BRANCH  
        {"BEQ",   (p) => [() => TranslateB(Instructions.branch, Branch.beq, p[0], p[1], p[2])]},
        {"BEQZ",  (p) => [() => TranslateB(Instructions.branch, Branch.beq, p[0], "x0", p[1])]},//Branch If Equal Zero
        {"BNE",   (p) => [() => TranslateB(Instructions.branch, Branch.bne, p[0], p[1], p[2])]},
        {"BNEZ",  (p) => [() => TranslateB(Instructions.branch, Branch.bne, p[0], "x0", p[1])]},//Branch If Not Equal Zero
        {"BLT",   (p) => [() => TranslateB(Instructions.branch, Branch.blt, p[0], p[1], p[2])]},
        {"BLTZ",  (p) => [() => TranslateB(Instructions.branch, Branch.blt, p[0], "x0", p[1])]},//Branch If Less than Zero
        {"BGT",   (p) => [() => TranslateB(Instructions.branch, Branch.blt, p[1], p[0], p[2])]},//Branch If Greater Than
        {"BGTZ",  (p) => [() => TranslateB(Instructions.branch, Branch.blt, "x0", p[0], p[1])]},//Branch If Greater Than Zero
        {"BLTU",  (p) => [() => TranslateB(Instructions.branch, Branch.bltu, p[0], p[1], p[2])]},
        {"BGTU",  (p) => [() => TranslateB(Instructions.branch, Branch.bltu, p[1], p[0], p[2])]},//Branch If Greater Than Unsigned
        {"BLE",   (p) => [() => TranslateB(Instructions.branch, Branch.bge, p[1], p[0], p[2])]},//Branch If Less Equal
        {"BGEZ",  (p) => [() => TranslateB(Instructions.branch, Branch.bge, p[0], "x0", p[1])]},//Branch If Greater or Equal Zero
        {"BGE",   (p) => [() => TranslateB(Instructions.branch, Branch.bge, p[0], p[1], p[2])]},
        {"BLEU",  (p) => [() => TranslateB(Instructions.branch, Branch.bgeu, p[1], p[0], p[2])]},//Branch If Less Equal Unsigned
        {"BGEU",  (p) => [() => TranslateB(Instructions.branch, Branch.bgeu, p[0], p[1], p[2])]},
        //LOAD
        {"LB",    (p) => [() => TranslateI(Instructions.load, DataSize.@byte, p[0], p[1], p[2])]},
        {"LBU",   (p) => [() => TranslateI(Instructions.load, DataSize.ubyte, p[0], p[1], p[2])]},
        {"LH",    (p) => [() => TranslateI(Instructions.load, DataSize.half, p[0], p[1], p[2])]},
        {"LHU",   (p) => [() => TranslateI(Instructions.load, DataSize.uhalf, p[0], p[1], p[2])]},
        {"LW",    (p) => [() => TranslateI(Instructions.load, DataSize.word, p[0], p[1], p[2])]},
        //STORE
        {"SB",    (p) => [() => TranslateS(Instructions.store, DataSize.@byte, p[0], p[1], p[2])]},
        {"SH",    (p) => [() => TranslateS(Instructions.store, DataSize.half, p[0], p[1], p[2])]},
        {"SW",    (p) => [() => TranslateS(Instructions.store, DataSize.word, p[0], p[1], p[2])]},
        {"SF",    (p) => [() => TranslateS(Instructions.store, DataSize.@float, p[0], p[1], p[2])]},
        //ALU-arithmetic
        {"ADDI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.addi, p[0], p[1], p[2])]},
        {"INC",   (p) => [() => TranslateI(Instructions.op_imm, Operation.addi, p[0], p[0], p[1])]},
        {"DEC",   (p) => [() => TranslateI(Instructions.op_imm, Operation.addi, p[0], p[0],(-(int)ToInteger(p[1],0xfff)).ToString())]},
        {"ADD",   (p) => [() => TranslateR(Instructions.op, Operation.add, p[0], p[1], p[2])]},
        {"SUB",   (p) => [() => TranslateR(Instructions.op, Operation.sub, p[0], p[1], p[2])]},
        {"NEG",   (p) => [() => TranslateR(Instructions.op, Operation.sub, p[0], "x0", p[1])]},//negate
        {"MUL",   (p) => [() => TranslateR(Instructions.op, Operation.mul, p[0], p[1], p[2])]},
        {"MULH",  (p) => [() => TranslateR(Instructions.op, Operation.mulh, p[0], p[1], p[2])]},
        {"MULHSU",(p) => [() => TranslateR(Instructions.op, Operation.mulhsu, p[0], p[1], p[2])]},
        {"MULHU", (p) => [() => TranslateR(Instructions.op, Operation.mulhu, p[0], p[1], p[2])]},
        {"DIV",   (p) => [() => TranslateR(Instructions.op, Operation.div, p[0], p[1], p[2])]},
        {"DIVU",  (p) => [() => TranslateR(Instructions.op, Operation.divu, p[0], p[1], p[2])]},
        {"REM",   (p) => [() => TranslateR(Instructions.op, Operation.rem, p[0], p[1], p[2])]},
        {"REMU",  (p) => [() => TranslateR(Instructions.op, Operation.remu, p[0], p[1], p[2])]},
        //ALU-logic
        {"XORI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.xori, p[0], p[1], p[2])]},
        {"ORI",   (p) => [() => TranslateI(Instructions.op_imm, Operation.ori, p[0], p[1], p[2])]},
        {"ANDI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.andi, p[0], p[1], p[2])]},
        {"AND",   (p) => [() => TranslateR(Instructions.op, Operation.and, p[0], p[1], p[2])]},
        {"OR",    (p) => [() => TranslateR(Instructions.op, Operation.or, p[0], p[1], p[2])]},
        {"XOR",   (p) => [() => TranslateR(Instructions.op, Operation.xor, p[0], p[1], p[2])]},
        {"NOT",   (p) => [() => TranslateI(Instructions.op_imm, Operation.xori, p[0], p[1], "-1")]},
        //ALU-comparison
        {"SLTI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.slti, p[0], p[1], p[2])]},
        {"SLTIU", (p) => [() => TranslateI(Instructions.op_imm, Operation.sltiu, p[0], p[1], p[2])]},
        {"SEQZ",  (p) => [() => TranslateI(Instructions.op_imm, Operation.sltiu, p[0], p[1], "1")]},//Set Equal Zero
        {"SNEZ",  (p) => [() => TranslateR(Instructions.op, Operation.sltu, p[0], "x0", p[1])]},//Set Not Equal Zero
        {"SLT",   (p) => [() => TranslateR(Instructions.op, Operation.slt, p[0], p[1], p[2])]},
        {"SLTZ",  (p) => [() => TranslateR(Instructions.op, Operation.slt, p[0], p[1], "x0")]},//Set Less Than Zero
        {"SLTU",  (p) => [() => TranslateR(Instructions.op, Operation.sltu, p[0], p[1], p[2])]},
        {"SGT",   (p) => [() => TranslateR(Instructions.op, Operation.slt, p[0], p[2], p[1])]},//Set Greater Than
        {"SGTZ",  (p) => [() => TranslateR(Instructions.op, Operation.slt, p[0], "x0", p[1])]},//Set Greater Than zero
        {"SGTU",  (p) => [() => TranslateR(Instructions.op, Operation.sltu, p[0], p[2], p[1])]},//Set Greater Than Unsigned
        //SHIFTER
        {"SLLI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.slli, p[0], p[1], p[2])]},
        {"SRLI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.srli, p[0], p[1], p[2])]},
        {"SRAI",  (p) => [() => TranslateI(Instructions.op_imm, Operation.srai, p[0], p[1],$"{ToInteger(p[2],0x1F)|0x400}")]},
        {"SLL",   (p) => [() => TranslateR(Instructions.op, Operation.sll, p[0], p[1], p[2])]},
        {"SRL",   (p) => [() => TranslateR(Instructions.op, Operation.srl, p[0], p[1], p[2])]},
        {"SRA",   (p) => [() => TranslateR(Instructions.op, Operation.sra, p[0], p[1], p[2])]},
        {"SEXT.B",(p) => [() => TranslateI(Instructions.op_imm, Operation.slli, p[0], p[1], "24"),//sign extend byte 
                          () => TranslateI(Instructions.op_imm, Operation.srai, p[0], p[1], "24")]},
        {"SEXT.H",(p) => [() => TranslateI(Instructions.op_imm, Operation.slli, p[0], p[1], "16"),//sign extend half-word
                          () => TranslateI(Instructions.op_imm, Operation.srai, p[0], p[1], "16")]},
        {"ZEXT.B",(p) => [() => TranslateI(Instructions.op_imm, Operation.andi, p[0], p[1], "0xff")]},//zero extend byte
        {"ZEXT.H",(p) => [() => TranslateI(Instructions.op_imm, Operation.slli, p[0], p[1], "16"),//zero extend half-word
                          () => TranslateI(Instructions.op_imm, Operation.srli, p[0], p[1], "16")]},
        //SYSTEM INSTRUCTIONS
        {"ECALL", (p) => [() => TranslateI(Instructions.system, SystemFunct20.ecall, "x0")]},
        {"EBREAK",(p) => [() => TranslateI(Instructions.system, SystemFunct20.ebreak, "x0")]},
        {"WFI",   (p) => [() => TranslateI(Instructions.system, SystemFunct20.wfi, "x0")]},
        {"MRET",  (p) => [() => TranslateI(Instructions.system, SystemFunct20.mret, "x0")]},

        {"CSRR",  (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrs, p[0], "x0", TryParseCSR(p[1]))]},
        {"CSRW",  (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrw, "x0", p[1], TryParseCSR(p[0]))]},
        {"CSRS",  (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrs, "x0", p[1], TryParseCSR(p[0]))]},
        {"CSRC",  (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrc, "x0", p[1], TryParseCSR(p[0]))]},

        {"CSRWI", (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrwi, "x0", "x" + ToInteger(p[1],0x1f), TryParseCSR(p[0]))]},
        {"CSRSI", (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrsi, "x0", "x" + ToInteger(p[1],0x1f), TryParseCSR(p[0]))]},
        {"CSRCI", (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrci, "x0", "x" + ToInteger(p[1],0x1f), TryParseCSR(p[0]))]},

        {"CSRRW", (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrw, p[0], p[2], TryParseCSR(p[1]))]},
        {"CSRRS", (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrs, p[0], p[2], TryParseCSR(p[1]))]},
        {"CSRRC", (p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrc, p[0], p[2], TryParseCSR(p[1]))]},

        {"CSRRWI",(p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrwi, p[0], "x" + ToInteger(p[2],0x1f), TryParseCSR(p[1]))]},
        {"CSRRSI",(p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrsi, p[0], "x" + ToInteger(p[2],0x1f), TryParseCSR(p[1]))]},
        {"CSRRCI",(p) => [() => TranslateI(Instructions.system, SystemFunct20.csrrci, p[0], "x" + ToInteger(p[2],0x1f), TryParseCSR(p[1]))]},
        //special pseudoinstructions
        {"LI",   (p) => { //Load Immediate
            if (IsAddress(p[1]))
            {
                throw new NotImplementedException("Variable addresses cannot be used with LI due to its variable size nature.");
            }
            int immediate = (int)ToInteger(p[1]);
            if (Math.Abs(Math.Clamp(immediate,-0x8000,0x8000)) <= 0x800)
                return [() => TranslateI(Instructions.op_imm, Operation.addi, p[0], "x0", p[1])];
            else if ((immediate & 0xfff) != 0)
                return [() => TranslateU(Instructions.lui, p[0], Upper(immediate)),
                        () => TranslateI(Instructions.op_imm, Operation.addi, p[0], p[0], p[1])];
            else
                return [() => TranslateU(Instructions.lui, p[0], Upper(immediate))];
        }},
        {"LA",   (p) => { //Load Address
            int immediate = IsAddress(p[1]) ? 0 : (int)ToInteger(p[1]);
            if (IsPositionIndependentCode)
            {
                return [() => TranslateU(Instructions.auipc, p[0], Upper(immediate)),
                        () => TranslateI(Instructions.load, DataSize.word, p[0], p[0], p[1])];
            }
            else
            {
                return [() => TranslateU(Instructions.auipc, p[0], Upper(immediate)),
                        () => TranslateI(Instructions.op_imm, Operation.addi, p[0], p[0], p[1])];                
            }
        }},
        {"CALL",  (p) => {//Call Far-Away subroutine
            if (IsAddress(p[0]))
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("(WARNING): Label used on CALL Instruction detect; this should be avoided for jumps further than 200000 addresses long due to CALL variable address length.");
                Console.ForegroundColor = ConsoleColor.White;
                p[0] = "0";
            }
            int immediate = (int)ToInteger(p[0]);
            if (Math.Abs(Math.Clamp(immediate,-0x8000,0x8000)) < 0x200000)
                return [() => TranslateJ(Instructions.jal, "ra", p[0])];
            else
                return [() => TranslateU(Instructions.auipc, "ra", Upper(immediate)),
                        () => TranslateI(Instructions.jalr, 0, "ra", "ra", p[0])];
        }},
    };
    public static readonly Dictionary<string, Func<string[], Func<uint>[]>> pseudoOps = new()
    {
        {".BYTE", (p) =>
        {
            List<Func<uint>> generators = [];
            bool hasLabel = !(char.IsDigit(p[0][0]) || p[0][0] == '-');
            int i;
            for(i = hasLabel ? 1 : 0; i + 3 < p.Length; i += 4)
            {
                var word = ToInteger(p[i],0xff) |
                            (ToInteger(p[i+1],0xff) << 8) |
                            (ToInteger(p[i+2],0xff) << 16) |
                            (ToInteger(p[i+3],0xff) << 24);
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }

            if(i < p.Length)
            {
                var word = ToInteger(p[i],0xff) |
                       (i + 1 < p.Length ? (ToInteger(p[i+1],0xff) << 8) : 0) |
                       (i + 2 < p.Length ? (ToInteger(p[i+2],0xff) << 16) : 0);
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }
            return [.. generators];
        }},
        {".HALF", (p) => {
            List<Func<uint>> generators = [];
            bool hasLabel = !(char.IsDigit(p[0][0]) || p[0][0] == '-');
            int i;
            for(i = hasLabel ? 1 : 0; i + 1 < p.Length; i += 2)
            {
                var word = ToInteger(p[i],0xffff) | (ToInteger(p[i+1]) << 16);
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }

            if(i < p.Length)
            {
                var word = ToInteger(p[i],0xffff);
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }
            return [.. generators];
        }},
        {".WORD", (p) => {
            List<Func<uint>> generators = [];
            bool hasLabel = !(char.IsDigit(p[0][0]) || p[0][0] == '-');
            for(int i = hasLabel ? 1 : 0; i < p.Length; i++)
            {
                uint word = ToInteger(p[i]);
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }
            return [.. generators];
        }},
        {".FLOAT", (p) => []},
        {".STRING", (p) => {
            List<Func<uint>> generators = [];
            bool hasLabel = p[0][0] != '"';
            var str = string.Join(' ', p[(hasLabel ? 1 : 0)..^0])[1..^1];
            int i;
            for(i = 0; i + 3 < str.Length; i += 4)
            {
                var word = str[i] |
                           (uint)str[i+1] << 8 |
                           (uint)str[i+2] << 16 |
                           (uint)str[i+3] << 24;
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }

            if(i < str.Length)
            {
                var word = str[i] |
                       (i + 1 < str.Length ? (uint)str[i+1] << 8 : 0) |
                       (i + 2 < str.Length ? (uint)str[i+2] << 16 : 0);
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(word));
                    Console.ForegroundColor = ConsoleColor.White;
                    return word;
                });
            }
            else
            {
                generators.Add(() => {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(ToBinary(0));
                    Console.ForegroundColor = ConsoleColor.White;
                    return 0;
                });
            }
            return [.. generators];
        }},
        {".OPTION", (p) => {
            Console.SetCursorPosition(Assembler.textPosition, Console.CursorTop);
            Console.ForegroundColor = ConsoleColor.Cyan;
            switch (p[0].ToUpper())
            {
                case "PIC":
                    Console.WriteLine("(INFO)Activating Position Independent Code Mode (.option pic)");

                    IsPositionIndependentCode = true;
                    break;
                case "NOPIC":
                    Console.WriteLine("(INFO)Disabling Position Independent Code Mode (.option nopic)");
                    IsPositionIndependentCode = false;
                    break;
            }
            Console.ForegroundColor = ConsoleColor.White;
            return [];
        }},
    };

    /// <summary>
    /// Defines the set of instructions that are PC-relative to calculate the value of the labels.
    /// </summary>
    public static HashSet<string> PCRelativeInstructions =>
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
        "CALL",
        "LGA",
        "LA"
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
    private static uint TranslateR(EnumConverter instruction, EnumConverter funct10, string rd, string rs1, string rs2)
    {
        uint result = instruction;

        result |= TryParseRegister(rd) << 7;

        result |= ((uint)funct10 & 0x7) << 12;

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
    private static uint TranslateI(EnumConverter instruction, EnumConverter funct3, string rd, string rs1, string imm12)
    {
        uint result = instruction;

        result |= TryParseRegister(rd) << 7;

        result |= ((uint)funct3 & 0x7) << 12;

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
    /// Used for system instructions translation that although follow the I-type, have a fixed rs1 field. 
    /// </summary>
    /// <param name="instruction">The opcode of the instruction.</param>
    /// <param name="funct20">The function that is being used.</param>
    /// <param name="rd">The destination register.</param>
    /// <returns></returns>
    private static uint TranslateI(EnumConverter instruction, EnumConverter funct20, string rd)
    {
        return TranslateI(instruction, funct20 & 0x7, rd, "x" + ((funct20 >> 3) & 0x1f), ((funct20 >> 8) & 0xfff).ToString());
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
    private static uint TranslateS(EnumConverter instruction, EnumConverter funct3, string rs2, string rs1, string imm12)
    {
        uint result = instruction;
        uint immediate = ToInteger(imm12, 0xFFF);

        result |= (immediate & 0x1F) << 7;
        result |= ((uint)funct3 & 0x7) << 12;

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
    private static uint TranslateB(EnumConverter instruction, EnumConverter funct3, string rs1, string rs2, string imm12)
    {
        uint result = instruction;
        uint immediate = ToInteger(imm12, 0x1FFF);

        result |= (immediate & 0x800) >> 4;
        result |= (immediate & 0x1E) << 7;
        result |= ((uint)funct3 & 0x7) << 12;

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
    private static uint TranslateU(EnumConverter instruction, string rd, string imm20)
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
    private static uint TranslateJ(EnumConverter instruction, string rd, string imm20)
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

    private static bool IsAddress(string text) => text.StartsWith(':') || text.StartsWith('.');

    /// <summary>
    /// Translates a string number to an integer.
    /// </summary>
    /// <param name="number"></param>
    /// <returns></returns>
    public static uint ToInteger(string number, uint mask = 0xffffffff)
    {
        if (number.StartsWith("0x"))
        {
            return uint.Parse(number[2..], System.Globalization.NumberStyles.AllowHexSpecifier) & mask;
        }
        if(int.TryParse(number, out int result))
        {
            return (uint)result;
        }
        return uint.Parse(number, System.Globalization.NumberStyles.Integer) & mask;
    }

    public static uint TryParseRegister(string register)
    {
        if (int.TryParse(register, out var _))
        {
            throw new ArgumentException($"Register not valid: \"{register}\"(Did you mean to use an immediate intruction?).");
        }
        if (Enum.TryParse<Register>(register, true, out var reg))
        {
            return (uint)reg;
        }
        throw new ArgumentException($"Register not valid: \"{register}\".");
    }

    public static string TryParseCSR(string csr)
    {
        if (int.TryParse(csr, out var _))
        {
            throw new ArgumentException($"CSR not valid: \"{csr}\".");
        }
        if (Enum.TryParse<CSR>(csr, true, out var reg))
        {
            return ((uint)reg).ToString();
        }
        throw new ArgumentException($"CSR not valid: \"{csr}\".");
    }

    public static string ToBinary(uint value) => Convert.ToString(value, 2).PadLeft(32, '0');

    /// <summary>
    /// Extracts the upper 20 bits of an immediate value while accounting for sign extension.
    /// </summary>
    /// <param name="immediate">The immediate integer value to be processed.</param>
    /// <returns>A string representing the upper portion of the immediate value, adjusted for sign extension.</returns>
    private static string Upper(int immediate) => ((immediate >> 12) + ((immediate & 0x800) >> 11)).ToString();
}