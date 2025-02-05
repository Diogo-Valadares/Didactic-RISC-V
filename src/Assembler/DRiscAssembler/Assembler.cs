namespace DRiscAssembler;
public class Assembler
{
    private static readonly string[] separator = ["\r\n", "\r", "\n"];

    public static string Assemble(string input, int bitWidth, int addressWidth)
    {
        var lines = input.Replace("\t", "").Split(separator, StringSplitOptions.None);
        var memory = new uint[2 << addressWidth];
        var linesList = lines.ToList();
        RemoveCommentsAndBlankLines(linesList);
        Dictionary<string, int> labels = ExtractLabels(linesList);
        Dictionary<string, uint> words = ExtractVariables(linesList);
        lines = [.. linesList];

        for (uint currentLine = 0; currentLine < lines.Length; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');

            switch (parts[0].ToUpper())
            {
                case ".WORD":
                    memory[currentLine] = Instruction.ToInteger(parts[2], 0xffffffff);
                    Console.Write($"\n[{currentLine}]:\t");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(Instruction.ToBinary(memory[currentLine]));
                    Console.ForegroundColor = ConsoleColor.Magenta;
                    Console.Write($" {parts[0]}");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write($" {parts[1]}");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write($" {parts[2]}");
                    Console.ForegroundColor = ConsoleColor.White;
                    continue;

            }

            if (!Instruction.instructions.TryGetValue(parts[0].ToUpper(), out var translator))
            {
                throw new Exception($"Unknown instruction \"{parts[0]}\" at line {currentLine}.");
            }
            Console.Write($"\n[{currentLine}]:\t");

            memory[currentLine] = translator(parts[1..]);
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Write($"  {parts[0]}");
            for (int i = 1; i < parts.Length; i++)
            {
                Console.ForegroundColor = ConsoleColor.Green;
                if (!int.TryParse(parts[i], out _) && Enum.TryParse(typeof(Register), parts[i], true, out _))
                {
                    Console.ForegroundColor = ConsoleColor.Cyan;
                }

                Console.Write($" {parts[i]}");
            }
            if (currentLine > 0 && ((memory[currentLine - 1] & 0x7f) == (uint)Instructions.load) &&
                (((memory[currentLine - 1] & 0xf80) >> 7) == ((memory[currentLine] & 0x1f00000) >> 20) ||
                ((memory[currentLine - 1] & 0xf80) >> 7) == ((memory[currentLine] & 0xf8000) >> 15)))
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.Write($"\n[WARNING] Hazard detected! {parts[0]} at {currentLine} uses a register that won't have time to load from the previous instruction.");
            }
            Console.ForegroundColor = ConsoleColor.White;
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
        Console.Write("\nCompilation Completed.\n");
        return output;
    }
    public static void PrintInstructions()
    {
        foreach (var instruction in Instruction.instructions)
        {
            Console.Write(instruction.Key + " ");
        }
    }

    private static void RemoveCommentsAndBlankLines(List<string> lines)
    {
        for (int currentLine = lines.Count - 1; currentLine >= 0; currentLine--)
        {
            var commentIndex = lines[currentLine].IndexOf("//");
            if (commentIndex >= 0) lines[currentLine] = lines[currentLine][0..commentIndex];
            commentIndex = lines[currentLine].IndexOf('#');
            if (commentIndex >= 0) lines[currentLine] = lines[currentLine][0..commentIndex];
            if (lines[currentLine] == "")
            {
                lines.RemoveAt(currentLine);
            }
        }
    }
    private static Dictionary<string, int> ExtractLabels(List<string> lines)
    {
        Dictionary<string, int> labels = [];
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            if (!lines[currentLine].StartsWith(':')) continue;
            labels.Add(lines[currentLine], (int)currentLine << 2);
            Console.WriteLine($"[{currentLine}]Added label \"{lines[currentLine]}\" with value {(int)currentLine << 2}");
            lines.RemoveAt(currentLine);
            currentLine--;
        }

        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');
            for (int i = 0; i < parts.Length; i++)
            {
                if (!parts[i].StartsWith(':')) continue;
                if (!labels.TryGetValue(parts[i], out var value))
                {
                    throw new Exception($"[{currentLine}]Unknown label \"{parts[i]}\" at line {currentLine}.");
                }

                var lineBefore = lines[currentLine];
                if (Instruction.PCRelativeInstructions.Contains(parts[0].ToUpper()))
                {
                    value -= currentLine << 2;
                }
                lines[currentLine] = lines[currentLine].Replace(parts[i], value.ToString());
                #region DebugPrint
                Console.Write($"[{currentLine}]Translated label at line from ");
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write($"\"{lineBefore}\"");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(" to ");
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"\"{lines[currentLine]}\"");
                Console.ForegroundColor = ConsoleColor.White;
                #endregion
            }
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

        if (words.Count > 0)
        {
            Console.WriteLine("\nVariables:");
            foreach (var word in words)
            {
                Console.WriteLine($"{word.Key} = {word.Value}");
            }
        }

        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');
            for (int i = 1; i < parts.Length; i++)
            {
                if (!parts[i].StartsWith('.')) continue;
                if (!words.TryGetValue(parts[i][1..], out var value))
                {
                    throw new Exception($"[{currentLine}]Unknown variable \"{parts[i]}\" at line {currentLine}.");
                }
                var lineBefore = lines[currentLine];
                lines[currentLine] = lines[currentLine].Replace(parts[i], value.ToString());
                #region DebugPrint
                Console.Write($"[{currentLine}]Translated variable at line from ");
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write($"\"{lineBefore}\"");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(" to ");
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"\"{lines[currentLine]}\"");
                Console.ForegroundColor = ConsoleColor.White;
                #endregion
            }
        }

        return words;
    }
}
