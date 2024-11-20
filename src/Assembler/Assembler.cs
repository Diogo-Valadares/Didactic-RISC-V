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
                else if (parts[2].StartsWith(':'))
                {
                    memory[address] = labels[parts[2]];
                }
                else                    
                {
                    memory[address] = uint.Parse(parts[2],intStyle);
                }
                continue;
            }

            if (parts[0][^1] == '*')
            {
                parts[0] = parts[0][0..^1];
            }
            else
            {
                memory[address] |= 1 << 24;
            }            

            //Operation
            if (!Enum.TryParse(parts[0].ToUpper(), out Instructions mnemonic))
            {
                throw new Exception($"Unknown instruction \"{parts[0]}\".");
            }
            memory[address] |= (uint)mnemonic << 25;
            Console.WriteLine($"\n{ToBinary((uint)mnemonic << 25)} Instruction {parts[0]}({memory[address]}) added to [{address}] with:");

            //Parameter1
            if (TryGetRegisterAddress(parts[1], out uint destination))
            {
                memory[address] |= destination << 19;
                PrintParameterDebug(destination << 19, "Destination", "x8");
            }
            else if (Enum.TryParse(parts[1].ToUpper(), out Condition condition))
            {
                memory[address] |= (uint)condition << 19;
                PrintParameterDebug((uint)condition << 19, $"Condition({condition})", "x8");
            }
            else
            {
                throw new Exception($"Invalid Register or Unknown condition \"{parts[1]}\".");
            }

            //Parameter2
            switch (parts[2][0])
            {
                case 'r':
                case 'R':
                    if (TryGetRegisterAddress(parts[2], out uint source1))
                    {
                        memory[address] |= source1 << 14;
                        PrintParameterDebug(source1 << 14, "Source 1", "x8");
                        break;
                    }
                    throw new Exception("Invalid Register: " + parts[2]);                                        
                case '.':
                    if (words.TryGetValue(parts[2][1..^0], out uint value))
                    {
                        memory[address] |= value;
                        PrintParameterDebug(value, "Variable Address (immediate 19bit)", "x8");
                        continue;
                    }
                    throw new Exception("Variable \"" + parts[2][1..^0] + "\" Not found");                    
                case ':':
                    if (labels.TryGetValue(parts[2], out value))
                    {
                        memory[address] |= value;
                        PrintParameterDebug(value, "Label Address (immediate 19bit)", "x8");
                        continue;
                    }
                    throw new Exception("Label \"" + parts[2][1..^0] + "\" Not found");
                case '#':
                    uint immediate = uint.Parse(parts[2][1..^0], hexStyle);
                    memory[address] |= immediate & 0x7FFFF;
                    PrintParameterDebug(immediate & 0x7FFFF, "immediate 19bit", "x8");
                    continue;
                default:
                    immediate = uint.Parse(parts[2], intStyle);
                    memory[address] |= immediate & 0x7FFFF;
                    PrintParameterDebug(immediate & 0x7FFFF, "immediate 19bit","");
                    continue;
            }
            
            //parameter 3
            switch (parts[3][0])
            {
                case 'r':
                case 'R':
                    if (TryGetRegisterAddress(parts[3], out uint source2))
                    {
                        memory[address] |= source2;
                        PrintParameterDebug(source2, "Source 2", "x8");
                        break;
                    }
                    throw new Exception("Invalid Register: " + parts[3]);
                case '.':
                    if (words.TryGetValue(parts[3][1..^0], out uint value))
                    {
                        memory[address] |= value;
                        memory[address] |= 1 << 13;
                        PrintParameterDebug(value, "Variable Address (Immediate)", "x8");
                        continue;
                    }
                    throw new Exception("Variable \"" + parts[3][1..^0] + "\" Not found");
                case ':':
                    if (labels.TryGetValue(parts[3], out value))
                    {
                        memory[address] |= value;
                        memory[address] |= 1 << 13;
                        PrintParameterDebug(value, "Label Address (immediate)", "x8");
                        continue;
                    }
                    throw new Exception("Label \"" + parts[3][1..^0] + "\" Not found");
                case '#':
                    uint immediate = uint.Parse(parts[3][1..^0], hexStyle);
                    memory[address] |= immediate & 0x1FFF;
                    memory[address] |= 1 << 13;
                    PrintParameterDebug(immediate & 0x1FFF, "Immediate", "x8");
                    continue;
                default:
                    immediate = uint.Parse(parts[3], intStyle);
                    memory[address] |= immediate & 0x1FFF;
                    memory[address] |= 1 << 13;
                    PrintParameterDebug(immediate & 0x1FFF, "Immediate", "");
                    continue;
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
    }

    private static void RemoveCommentsAndBlankLines(List<string> lines)
    {
        for (int currentLine = lines.Count - 1; currentLine >= 0 ; currentLine--)
        {
            var commentIndex = lines[currentLine].IndexOf("//");
            if (commentIndex >= 0) lines[currentLine] = lines[currentLine][0..(commentIndex)];
            if (lines[currentLine] == "")
            {
                lines.RemoveAt(currentLine);
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
                case ".byte":
                    throw new NotImplementedException();
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
        if (!text.StartsWith('r') && !text.StartsWith('R')) return false;
        if (text.Equals("rzero") || text.Equals("Rzero")) return true;
        address = uint.Parse(text[1..], intStyle);
        return true;
    }

    private static void PrintParameterDebug(uint value, string parameterName, string format)
    {
        Console.WriteLine($"{ToBinary(value)} {parameterName}: {value.ToString(format)}");
    }

    private static string ToBinary(uint value) => Convert.ToString(value, 2).PadLeft(32, '0');

    [System.Text.RegularExpressions.GeneratedRegex(@"\A\b(0[xX])?[0-9a-fA-F]+\b\Z")]
    private static partial System.Text.RegularExpressions.Regex IsHex();
}
