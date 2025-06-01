namespace DRiscAssembler;
public class Assembler
{
    public static int textPosition => 12;
    private static readonly string[] separator = ["\r\n", "\r", "\n"];

    public static string Assemble(string input, int bitWidth, int addressWidth)
    {
        var lines = input.Replace('\t', ' ').Replace(',', ' ').Split(separator, StringSplitOptions.None);
        var memory = new uint[2 << addressWidth];
        var linesList = lines.ToList();
        RemoveCommentsAndBlankLines(linesList);
        ExtractMacros(linesList);
        ExtractLabelsAndVariables(linesList);
        lines = [.. linesList];
        Console.Write($"[Line][Memory_Address] Translated_Binary Original_Code\n");
        int memIndex = 0;
        for (uint currentLine = 0; currentLine < lines.Length; currentLine++)
        {            
            var parts = splitLine(lines[currentLine]);

            /*switch (parts[0].ToUpper())
            {
                case ".WORD":
                    bool hasLabel = !int.TryParse(parts[1][0].ToString(), out var _);

                    for(int i = hasLabel ? 2 : 1; i < parts.Length; i++)
                    {
                        memory[memIndex] = Instruction.ToInteger(parts[i], 0xffffffff);
                        memIndex++;
                        #region Debug Print
                        Console.Write($"[{currentLine}]:\t");
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.Write(Instruction.ToBinary(memory[memIndex]));
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        Console.Write($" {parts[0]}");
                        if (hasLabel)
                        {
                            Console.ForegroundColor = ConsoleColor.Yellow;
                            Console.Write($" {parts[1]}");
                            Console.ForegroundColor = ConsoleColor.Green;
                            Console.Write($" {parts[i]}");
                        }
                        else
                        {
                            Console.ForegroundColor = ConsoleColor.Green;
                            Console.Write($" {parts[i]}");
                        }
                        Console.ForegroundColor = ConsoleColor.White;
                        Console.WriteLine();
                        #endregion
                    }
                    continue;
            }*/

            if (!Instruction.instructions.TryGetValue(parts[0].ToUpper(), out var translatorsGenerator) &&
                !Instruction.pseudoOps.TryGetValue(parts[0].ToUpper(), out translatorsGenerator))
            {
                //probably already gets filtered on labels and words extraction
                throw new InvalidOperationException($"Unknown instruction \"{parts[0]}\" at line {currentLine}.");
            }

            Console.Write($"[{currentLine}]");

            var translators = translatorsGenerator(parts[1..]);
            if (translators.Length == 0) continue;

            Console.Write($"[{memIndex}]");
            Console.SetCursorPosition(textPosition, Console.CursorTop);

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
                Console.SetCursorPosition($"[{currentLine}]".Length, Console.CursorTop);
                Console.Write($"[{memIndex}]");
                Console.SetCursorPosition(textPosition, Console.CursorTop);
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
            var parts = splitLine(lines[currentLine]);
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
            var parts = splitLine(lines[currentLine]);
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
    private static void ExtractLabelsAndVariables(List<string> lines)
    {
        Dictionary<string, int> labels = [];
        Dictionary<string, uint> words = [];

        string[] variablesTypes = [".byte", ".half", ".word", ".float", ".string"];

        int currentAddress = 0;     
        //indexing labels and variables
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = splitLine(lines[currentLine]);
            var (opSize, hasLabel) = getOperationInfo(parts, currentLine);
            if (variablesTypes.Contains(parts[0]) && hasLabel)
            {
                words.Add(parts[1], (uint)currentAddress << 2);
            }
            currentAddress += opSize;
            if (!lines[currentLine].StartsWith(':')) continue;
            
            labels.Add(lines[currentLine], currentAddress << 2);

            Console.WriteLine($"[{currentLine}]Added label \"{lines[currentLine]}\" with value {currentAddress << 2}");
            
            lines.RemoveAt(currentLine);
            currentLine--;
            currentAddress--;
        }

        //debug print
        if (words.Count > 0)
        {
            Console.WriteLine("\nVariables:");
            foreach (var word in words)
            {
                Console.WriteLine($"{word.Key} = {word.Value}");
            }
        }

        //swapping references for values
        currentAddress = 0;
        for (int currentLine = 0; currentLine < lines.Count; currentLine++)
        {
            var parts = splitLine(lines[currentLine]);            

            //label
            for (int i = 0; i < parts.Length; i++)
            {
                if (!parts[i].StartsWith(':')) continue;
                if (!labels.TryGetValue(parts[i], out var value))
                {
                    throw new Exception($"[{currentLine}]Unknown label \"{parts[i]}\" at line {currentLine}.");
                }

                var lineBefore = lines[currentLine];// for the debug print

                if (Instruction.PCRelativeInstructions.Contains(parts[0].ToUpper()))
                {
                    value -= currentAddress << 2;
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
            //variables
            for (int i = 1; i < parts.Length; i++)
            {
                if (!parts[i].StartsWith('.')) continue;
                if (!words.TryGetValue(parts[i][1..], out var value))
                {
                    throw new Exception($"[{currentLine}]Unknown variable \"{parts[i]}\" at line {currentLine}.");
                }
                var lineBefore = lines[currentLine];//for the DebugPrint
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

            var (size, _) = getOperationInfo(parts, currentLine);
            currentAddress += size;
        }   
    }
    private static string[] splitLine(string line) => line.Split(' ').Where((s) => s != string.Empty).ToArray();

    /// <summary>
    /// Used to extract Labels and the amount of 32 memory addresses that will be written by the operation;
    /// </summary>
    /// <param name="parts"></param>
    /// <param name="currentLine"></param>
    /// <returns></returns>
    /// <exception cref="InvalidOperationException"></exception>
    private static (int size, bool hasLabel) getOperationInfo(string[] parts, int currentLine)
    {
        bool hasLabel = false;
        int size = 0;
        switch (parts[0])
        {
            case ".byte":
                hasLabel = !char.IsDigit(parts[1][0]);
                size = (int)Math.Ceiling(parts.Length - (hasLabel ? 2 : 1) / 4f);
                break;
            case ".half":
                hasLabel = !char.IsDigit(parts[1][0]);                
                size = (int)Math.Ceiling(parts.Length - (hasLabel ? 2 : 1) / 2f);
                break;
            case ".word":
            case ".float":
                hasLabel = !char.IsDigit(parts[1][0]);  
                size = parts.Length - (hasLabel ? 2 : 1);
                break;
            case ".string":
                hasLabel = parts[1][0] != '"';
                size = parts[hasLabel ? 2 : 1].Length - 2;
                break;
            default:                
                if (!parts[0].StartsWith('.') && !parts[0].StartsWith(':')) {
                    //regular instructions
                    if(!Instruction.instructions.TryGetValue(parts[0].ToUpper(), out var translators))
                    {
                        throw new InvalidOperationException($"Unknown instruction \"{parts[0]}\" at line {currentLine}.");
                    }
                    size = translators(parts[1..]).Length;
                }
                //Operations that aren't variables shouldn't have size. 
                break;
        }
        return (size, hasLabel);
    }
}
