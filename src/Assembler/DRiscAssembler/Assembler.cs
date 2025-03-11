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
        ExtractMacros(linesList);
        ExtractLabels(linesList);
        ExtractVariables(linesList);
        lines = [.. linesList];

        int memIndex = 0;
        for (uint currentLine = 0; currentLine < lines.Length; currentLine++)
        {            
            var parts = lines[currentLine].Split(' ');

            switch (parts[0].ToUpper())
            {
                case ".WORD":
                    memory[currentLine] = Instruction.ToInteger(parts[parts.Length > 2 ? 2 : 1], 0xffffffff);
                    #region Debug Print
                    Console.Write($"[{currentLine}]:\t");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(Instruction.ToBinary(memory[currentLine]));
                    Console.ForegroundColor = ConsoleColor.Magenta;
                    Console.Write($" {parts[0]}");
                    if(parts.Length > 2)
                    {
                        Console.ForegroundColor = ConsoleColor.Yellow;
                        Console.Write($" {parts[1]}");
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.Write($" {parts[2]}");
                    }
                    else
                    {
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.Write($" {parts[1]}");
                    }
                    Console.ForegroundColor = ConsoleColor.White;
                    Console.WriteLine();
                    #endregion
                    continue;
            }

            if (!Instruction.instructions.TryGetValue(parts[0].ToUpper(), out var translatorsGenerator))
            {
                throw new Exception($"Unknown instruction \"{parts[0]}\" at line {currentLine}.");
            }
            Console.Write($"[{currentLine}]:");

            var translators = translatorsGenerator(parts[1..]);

            memory[memIndex] = translators[0]();
            memIndex++;

            #region Debug Print
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
            Console.ForegroundColor = ConsoleColor.White;
            Console.WriteLine();
            #endregion

            //in case it gets translated into more than one line
            for (int i = 1; i < translators.Length; i++)
            {
                memory[memIndex] = translators[i]();
                memIndex++;
                Console.WriteLine();
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
            lines[currentLine] = lines[currentLine].Trim();
            if (lines[currentLine] == "")
            {
                lines.RemoveAt(currentLine);
            }            
        }
    }
    private static void ExtractMacros(List<string> lines)
    {
        Dictionary<string, (string[] arguments, string[] macro)> macros = [];
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');
            if (parts[0] != ".macro") continue;;
            var macroName = parts[1];
            var macroArgs = parts[2..];
            lines.RemoveAt(currentLine);

            if(macroArgs.Distinct().Count() != macroArgs.Length)
            {
                throw new Exception($"[{currentLine}]Duplicate arguments in " +
                    $"macro \"{macroName}\" ({string.Join(" ", macroArgs)}).");
            }
            else if (Instruction.instructions.TryGetValue(macroName.ToUpper(), out var _))
            {
                throw new Exception($"[{currentLine}]Macro \"{macroName}\" has the same name as an instruction.");
            }
            else if (macros.ContainsKey(macroName))
            {
                throw new Exception($"[{currentLine}]Macro \"{macroName}\" already exists.");
            }

            List<string> macroLines = [];            
            while (currentLine != lines.Count && lines[currentLine] != ".endmacro")
            {
                if (lines[currentLine].StartsWith(".macro")) 
                {
                    throw new Exception($"[{currentLine}]Nested macros are not allowed. At macro \"{macroName}\".");
                } 
                macroLines.Add(lines[currentLine]);
                lines.RemoveAt(currentLine);
            }
            lines.RemoveAt(currentLine);
            currentLine--;
            #region DebugPrint
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"Macro \"{macroName}\" added:");
            Console.ForegroundColor = ConsoleColor.Magenta;
            Console.WriteLine($"Args: {string.Join(" ", macroArgs)}");
            Console.ForegroundColor = ConsoleColor.White;
            Console.WriteLine($"Macro: \n{string.Join("\n", macroLines)}\n");
            #endregion
            macros.Add(macroName, (macroArgs, macroLines.ToArray()));
        }

        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');
            if (!macros.TryGetValue(parts[0], out (string[] arguments, string[] macroLines) value)) continue;
            
            if(parts.Length - 1 != value.arguments.Length)
            {
                throw new Exception($"[{currentLine}]Macro \"{parts[0]}\" requires " +
                    $"{value.arguments.Length} arguments, but {parts.Length - 1} were provided({string.Join(" ", parts[1..])}).");
            }

            lines.RemoveAt(currentLine);

            foreach (var line in value.macroLines)
            {
                var translatedLine = line;
                for (int i = 0; i < value.arguments.Length; i++)
                {
                    translatedLine = translatedLine.Replace(value.arguments[i], parts[i + 1]);
                }
                lines.Insert(currentLine,translatedLine);
                currentLine++;
            }
            currentLine--;
            #region DebugPrint
            Console.Write("Macro");
            Console.ForegroundColor = ConsoleColor.Green;
            Console.Write($"\"{parts[0]}\"");
            Console.ForegroundColor = ConsoleColor.White;
            Console.Write("inserted with args = ");
            Console.ForegroundColor = ConsoleColor.Magenta;
            Console.Write($"{string.Join(" ",parts[1..])}\n");
            Console.ForegroundColor = ConsoleColor.White;
            #endregion
        }
    }
    private static void ExtractLabels(List<string> lines)
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
    }
    private static void ExtractVariables(List<string> lines)
    {
        Dictionary<string, uint> words = [];
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = lines[currentLine].Split(' ');
            switch (parts[0].ToUpper())
            {
                case ".WORD":
                    if(parts.Length > 2)
                    {
                        words.Add(parts[1], (uint)currentLine << 2);
                    }                    
                    break;
                case ".HALF":
                case ".BYTE":
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
    }
}
