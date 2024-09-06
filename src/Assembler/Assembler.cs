namespace RiscAssembler;
public partial class Assembler
{
    private static readonly string[] separator = ["\r\n", "\r", "\n"];
    private static readonly System.Globalization.NumberStyles hexStyle = System.Globalization.NumberStyles.HexNumber;
    private static readonly System.Globalization.NumberStyles intStyle = System.Globalization.NumberStyles.Integer;

    /// <summary>
    /// Translates an assembly program into machine code.
    /// Instruction format: 
    /// Type 1 mnemonic [!SCC] destination|condition source1 source2|value [//comment]
    /// Type 2 mnemonic [!SCC] destination|condition value [//comment]
    /// 
    /// Variable creation:
    /// .word name value
    /// 
    /// Label Creation:
    /// :label
    /// 
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    public static string Assemble(string input, int bitWidth, int addressWidth)
    {
        var lines = input.Replace("\t", "").Split(separator, StringSplitOptions.None);
        var memory = new uint[2 << addressWidth];


        var linesList = lines.ToList();
        RemoveCommentsAndBlankLines(linesList);
        Dictionary<string, uint> labels = ExtractLabels(linesList);
        Dictionary<string, uint> words = ExtractVariables(linesList);
        lines = [.. linesList];

        for (uint currentLine = 0, address = 0; currentLine < lines.Length; currentLine++, address++)
        {           
            Console.WriteLine("\nCurrent line: " + lines[currentLine]);
            var parts = lines[currentLine].Split(' ');

            if (parts[0].StartsWith('.'))
            {
                if (parts[2].StartsWith('#'))
                {
                    memory[address] = uint.Parse(parts[2][1..^0],hexStyle);
                }
                else                    
                {
                    memory[address] = uint.Parse(parts[2],intStyle);
                }
                continue;
            }

            //Operation
            if (!Enum.TryParse(parts[0], out Instructions mnemonic))
            {
                Console.WriteLine($"Unknown instruction \"{parts[0]}\". Ignoring.\n");
                continue;
            }
            memory[address] = (uint)mnemonic << 25;
            Console.WriteLine($"\n{ToBinary((uint)mnemonic << 25)} Instruction {parts[0]}({memory[address]}) added to [{address}] with:");
            
            //Parameter1
            if (TryGetRegisterAddress(parts[1], out uint destination))
            {
                memory[address] |= destination << 19;
                Console.WriteLine($"{ToBinary(destination << 19)} Destination: {destination}");
            }
            else if (Enum.TryParse(parts[1], out Condition condition))
            {
                memory[address] |= (uint)condition << 19;
                Console.WriteLine($"{ToBinary((uint)condition << 19)} Condition: {condition}({(uint)condition})");
            }
            else
            {
                Console.WriteLine($"Unknown condition \"{parts[1]}\". Ignoring.\n");
                continue;
            }

            //Parameter2
            switch (parts[2][0])
            {
                case '@':
                    if (TryGetRegisterAddress(parts[2], out uint source1))
                    {
                        memory[address] |= source1 << 14;
                        Console.WriteLine($"{ToBinary(source1 << 14)} Source 1: {source1}");
                    }
                    break;
                case '.':
                    if (words.TryGetValue(parts[2][1..^0], out uint value))
                    {
                        memory[address] |= value;
                        Console.WriteLine($"{ToBinary(value)} Variable Address (immediate High): {value}({parts[2]})");
                    }
                    else
                    {
                        throw new Exception("Variable \"" + parts[2][1..^0] + "\" Not found");
                    }
                    break;
                case ':':
                    if (labels.TryGetValue(parts[2], out value))
                    {
                        memory[address] |= value;
                        Console.WriteLine($"{ToBinary(value)} Address (immediate High): {value}({parts[2]})");
                    }
                    break;
                case '#':
                    uint immediate = uint.Parse(parts[2][1..^1], hexStyle);
                    memory[address] |= immediate & 0x7FFFF;
                    Console.WriteLine($"{ToBinary(immediate)} Immediate high: {immediate}");
                    continue;
                default:
                    immediate = uint.Parse(parts[2], intStyle);
                    memory[address] |= immediate & 0x7FFFF;
                    Console.WriteLine($"{ToBinary(immediate)} Immediate high: {immediate}");
                    continue;
            }
            //parameter 3
            switch (parts[3][0])
            {
                case '@':
                    if (TryGetRegisterAddress(parts[3], out uint source2))
                    {
                        memory[address] |= source2;
                        Console.WriteLine($"{ToBinary(source2)} Source 2: {source2}");
                    }
                    break;
                case '.':
                    if (words.TryGetValue(parts[3][1..^0], out uint value))
                    {
                        memory[address] |= value;
                        memory[address] |= 1 << 13;
                        Console.WriteLine($"{ToBinary(value)} Variable Address (Immediate): {value}({parts[3]})");
                    }
                    else
                    {
                        throw new Exception("Variable \"" + parts[3][1..^0] + "\" Not found");
                    }
                    break;
                case ':':
                    if (labels.TryGetValue(parts[3], out value))
                    {
                        memory[address] |= value;
                        memory[address] |= 1 << 13;
                        Console.WriteLine($"{ToBinary(value)} Address (immediate): {value}({parts[3]})");
                    }
                    break;
                case '#':
                    uint immediate = uint.Parse(parts[3][1..^1], hexStyle);
                    memory[address] |= immediate & 0x1FFF;
                    Console.WriteLine($"{ToBinary(immediate)} Immediate: {immediate}");
                    continue;
                default:
                    immediate = uint.Parse(parts[3], intStyle);
                    memory[address] |= immediate & 0x1FFF;
                    memory[address] |= 1 << 13;
                    Console.WriteLine($"{ToBinary((immediate) | (1 << 13))} Immediate: {immediate}");
                    continue;
            }

            //Flags
            if (parts.Length > 4 && parts[4].Equals("NO_CONDITION_SET"))
            {
                memory[address] |= 0 << 24;
                Console.WriteLine($"{ToBinary(1 << 24)} No condition set flag");
            }
            else
            {
                memory[address] |= 1 << 24;
            }
        }

        var output = "v3.0 hex words addressed";
        uint mask = uint.MaxValue >> (32 - bitWidth);
        for (int i = 0, address = 0; i < memory.Length; i++, address += 32 / bitWidth)
        {
            if (i % (bitWidth / 2) == 0) output += $"\n{address:x8}:";

            for (int j = 0; j <= 32 - bitWidth; j += bitWidth)
            {
                var portion = (memory[i] >> j) & mask;
                output += $" {portion.ToString($"x{bitWidth / 4}")}";
            }
        }
        return output;

        void InsertInMemory(uint value, uint address, Parameter parameter)
        {
            switch (parameter)
            {
                case Parameter.OperationCode:
                    memory![address] |= value << 25;
                    break;
                case Parameter.SetConditionCodes:
                    memory![address] |= value << 19;
                    break;
                case Parameter.Destination:
                case Parameter.Condition:
                    memory![address] |= value << 19;
                    break;
                case Parameter.Source1:
                case Parameter.Immediate19bit:
                    memory![address] |= value << 14;
                    break;
                case Parameter.Immediate13bit:
                    memory![address] |= 1 << 13;
                    memory![address] |= value;
                    break;
                case Parameter.Source2:
                    memory![address] |= value;
                    break;
            }
        }
    }

    private static void RemoveCommentsAndBlankLines(List<string> lines)
    {
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var commentIndex = lines[currentLine].IndexOf("//");
            if (commentIndex >= 0) lines[currentLine] = lines[currentLine][0..(commentIndex)];

            if (lines[currentLine] == "")
            {
                lines.RemoveAt(currentLine);
                currentLine--;
                continue;
            }
        }
    }
    private static Dictionary<string, uint> ExtractLabels(List<string> lines)
    {
        Dictionary<string, uint> labels = [];
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            if (!lines[currentLine].StartsWith(':')) continue;
            labels.Add(lines[currentLine], (uint)currentLine << 2);
            lines.RemoveAt(currentLine);
            currentLine--;
        }
        return labels;
    }
    private static Dictionary<string, uint> ExtractVariables(List<string> lines)
    {
        Dictionary<string, uint> words = [];
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');
            switch (parts[0])
            {
                case ".word":
                    words.Add(parts[1], (uint)currentLine << 2);
                    break;
                case ".short":
                case ".half":
                    throw new NotImplementedException();
                    break;
                case ".byte":
                    throw new NotImplementedException();
                    break;
            }
        }
        return words;
    }
    /// <summary>
    /// Receives a string and tries to parse it as a register address.
    /// </summary>
    /// <param name="text"></param>
    /// <param name="address"></param>
    /// <returns></returns>
    private static bool TryGetRegisterAddress(string text, out uint address)
    {
        address = 0;
        if (!text.StartsWith('@')) return false;
        if (text.Equals("@zero")) return true;
        address = uint.Parse(text[1..], intStyle);
        return true;
    }

    private static string ToBinary(uint value) => Convert.ToString(value, 2).PadLeft(32, '0');

    [System.Text.RegularExpressions.GeneratedRegex(@"\A\b(0[xX])?[0-9a-fA-F]+\b\Z")]
    private static partial System.Text.RegularExpressions.Regex IsHex();
}
