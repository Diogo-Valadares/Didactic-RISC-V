var filename = Console.ReadLine();
var file = File.Open($"{filename}.asm",FileMode.Open);
var reader = new StreamReader(file);
var input = reader.ReadToEnd();
var output = Assembler.Assembler.Assemble(input);

Console.Write(output);