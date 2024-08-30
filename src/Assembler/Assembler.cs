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
    /// 
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    public static string Assemble(string input)
    {
        var lines = input.Replace("\t", "").Split(separator, StringSplitOptions.None);
        var memory = new uint[256];
        Dictionary<string, byte> labels = [];

        for (int currentLine = 0, address = 0; currentLine < lines.Length; currentLine++, address++)
        {
            var commentIndex = lines[currentLine].IndexOf("//");
            if (commentIndex >= 0) lines[currentLine] = lines[currentLine][0..commentIndex];

            if (lines[currentLine] == "")
            {
                address--;
                continue;
            }

            var parts = lines[currentLine].Split(' ');
            if (parts.Length == 0) continue;
            /*
                        switch (instructions[i][0])
                        {
                            case ':'://used to define labels to be used in goto
                                labels.Add(parts[0][1..], (byte)x);
                                continue;
                            case '#'://used to define a contiguos memory block starting from an address                   
                                for (int n = 0; n < parts.Length; n++)
                                {
                                    memory[int.Parse(parts[0][1..], hexStyle) + n] = byte.Parse(parts[n], hexStyle);
                                }
                                continue;
                            case '@'://used to define a contiguos memory block that ends in the address 
                                for (int n = 0; n < parts.Length; n++)
                                {
                                    memory[int.Parse(parts[0][1..], hexStyle) - n] = byte.Parse(parts[n], hexStyle);
                                }
                                continue;
                        }
            */

            if (!Enum.TryParse(parts[0], out Instructions mnemonic))
            {
                Console.WriteLine($"Unknown instruction \"{parts[0]}\". Ignoring.\n");
                continue;
            }
            memory[address] = (uint)mnemonic;
            Console.WriteLine($"\n{ToBinary((uint)mnemonic)} Instruction {parts[0]}({memory[address]}) added to [{address}] with:");

            if (TryGetRegisterAddress(parts[1], out uint destination))
            {
                memory[address] |= destination << 8;
                Console.WriteLine($"{ToBinary(destination << 8)} Destination: {destination}");
            }
            else if (Enum.TryParse(parts[1], out Condition condition))
            {
                memory[address] |= (uint)condition << 8;
                Console.WriteLine($"{ToBinary((uint)condition << 8)} Condition: {condition}({(uint)condition})");
            }
            else
            {
                Console.WriteLine($"Unknown condition \"{parts[1]}\". Ignoring.\n");
                continue;
            }


            if (TryGetRegisterAddress(parts[2], out uint source1))
            {
                memory[address] |= source1 << 13;
                Console.WriteLine($"{ToBinary(source1 << 13)} Source 1: {source1}");
            }
            else
            {
                uint immediate = uint.Parse(parts[2], intStyle);
                memory[address] |= immediate << 13;
                Console.WriteLine($"{ToBinary(immediate << 13)} Immediate high: {immediate<<12}");
                continue;
            }

            if (TryGetRegisterAddress(parts[3], out uint source2))
            {
                memory[address] |= source2 << 27;
                Console.WriteLine($"{ToBinary(source2 << 27)} Source 2: {source2}");
            }
            else
            {
                uint immediate = uint.Parse(parts[3], intStyle);
                memory[address] |= immediate << 19;
                memory[address] |= 1 << 18;
                Console.WriteLine($"{ToBinary((immediate << 19) | (1 << 18))} Immediate: {immediate}");
            }

            if (parts.Length > 4 && parts[4].Equals("NO_CONDITION_SET"))
            {
                memory[address] |= 0 << 7;
                Console.WriteLine($"{ToBinary(1 << 7)} No condition set flag");
            }
            else
            {
                memory[address] |= 1 << 7;
            }
        }

        Console.WriteLine();
        var output = "v3.0 hex words addressed";
        for (int i = 0; i < memory.Length; i++)
        {
            if (i % 16 == 0) output += $"\n{i:x8}:";
            
            output += $" {memory[i]:x8}";
        }
        return output;
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
