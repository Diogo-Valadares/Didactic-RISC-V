//compile with "dotnet publish -r win-x64 -c Release"
using System.Text.RegularExpressions;

const string version = "v1.0";
string configFilePath = Path.Combine(Directory.GetCurrentDirectory(), "config.cfg");
Dictionary<string, string> configSettings = [];

if (File.Exists(configFilePath))
{
    string[] lines = File.ReadAllLines(configFilePath);
    foreach (string line in lines)
    {
        if (string.IsNullOrWhiteSpace(line) || !line.Contains('=')) continue;
        string[] parts = line.Split('=');
        if (parts.Length != 2) continue;
        configSettings[parts[0].Trim()] = parts[1].Trim();
    }
}
else
{
    configSettings.Add("searchFolder", "./");
    configSettings.Add("destination", "./program/");
    configSettings.Add("bitWidth", "8");
    configSettings.Add("addressWidth", "10");
    configSettings.Add("assemblerVersion", "DRisc");
    WriteConfigFile();
}

bool validOption = false;
int fileNumber = 0;
List<string> fileNames = [];
while (!validOption)
{
    Console.Clear();
    fileNames.Clear();
    fileNumber = 0;

    Console.WriteLine("DRISC-V Assembler " + version);
    Console.WriteLine("Current Folder(f to change): " + configSettings["searchFolder"]);
    Console.WriteLine("Current Output Folder(o to change): " + configSettings["destination"]);
    Console.WriteLine("Current Address Width(a to change): " + configSettings["addressWidth"]);

    string[] files = Directory.GetFiles(configSettings["searchFolder"], "*.*", SearchOption.TopDirectoryOnly);

    foreach (string file in files)
    {
        if (file.EndsWith(".dasm") || file.EndsWith(".txt"))
        {
            fileNames.Add(Path.GetFileName(file));
        }
    }
    Console.WriteLine("Choose a file to assemble(q to quit): \n");
    foreach (string fileName in fileNames)
    {
        Console.WriteLine(fileNumber + "-" + fileName);
        fileNumber++;
    }

    var option = Console.ReadLine();
    if (!int.TryParse(option, out fileNumber))
    {
        switch (option)
        {
            case "f":
                string searchPath;
                do
                {
                    Console.WriteLine("Insert the Search Folder: ");
                    searchPath = Console.ReadLine()!;
                    if (string.IsNullOrWhiteSpace(searchPath) || !Directory.Exists(searchPath))
                    {
                        Console.WriteLine("Invalid path. Please enter a valid existing folder.");
                    }
                } while (string.IsNullOrWhiteSpace(searchPath) || !Directory.Exists(searchPath));

                configSettings["searchFolder"] = searchPath;
                WriteConfigFile();
                break;

            case "o":
                string outputPath;
                do
                {
                    Console.WriteLine("Insert the Output Folder: ");
                    outputPath = Console.ReadLine()!;
                    if (string.IsNullOrWhiteSpace(outputPath) || !Directory.Exists(outputPath))
                    {
                        Console.WriteLine("Invalid path. Please enter a valid existing folder.");
                    }
                } while (string.IsNullOrWhiteSpace(outputPath) || !Directory.Exists(outputPath));

                configSettings["destination"] = outputPath;
                WriteConfigFile();
                break;
            case "a":
                string? line;
                do
                {
                    Console.WriteLine("Insert the address width: ");
                    line = Console.ReadLine()!;
                    if (string.IsNullOrWhiteSpace(line) || !int.TryParse(line, out _))
                    {
                        Console.WriteLine("Invalid address width. Please enter a valid number.");
                    }
                } while (string.IsNullOrWhiteSpace(line) || !int.TryParse(line, out _));

                configSettings["addressWidth"] = line;
                WriteConfigFile();
                break;
            case "q":
                return;
            default:
                Console.WriteLine("Invalid Option");
                Console.ReadKey();
                break;
        }
    }
    else if(fileNumber >= fileNames.Count)
    {
        Console.WriteLine("Invalid Number");
        Console.ReadKey();
    }
    else
    {
        validOption = true;
    }
}

var targetFile = $"{configSettings["searchFolder"]}{fileNames[fileNumber]}";
var fileContents = File.Open(targetFile, FileMode.Open);
var reader = new StreamReader(fileContents);
var input = reader.ReadToEnd();
string output = "";
try
{
    if (configSettings.TryGetValue("assemblerVersion",out var value) && value == "DRisc")
    {
        output = DRiscAssembler.Assembler.Assemble(input, int.Parse(configSettings["bitWidth"]), int.Parse(configSettings["addressWidth"]) - 2);
    }
    else
    {
        output = RiscAssembler.Assembler.Assemble(input, int.Parse(configSettings["bitWidth"]), int.Parse(configSettings["addressWidth"]) - 2);
    }
}
catch(Exception e)
{
    Console.WriteLine(e.Message + "\n\n");
    Console.WriteLine(e.StackTrace);
}

var compiledFilePath = $"{configSettings["destination"]}{fileNames[fileNumber][..fileNames[fileNumber].LastIndexOf('.')]}.mem";
var compiledFile = File.CreateText(compiledFilePath);
compiledFile.Write(output);
compiledFile.Flush();

Console.WriteLine("Do you wish to also save a file for the SystemVerilog simulation(y/n)?");
var op = Console.ReadKey();

if(op.KeyChar == 'y')
{
    compiledFilePath = $"{configSettings["destination"]}{fileNames[fileNumber][..fileNames[fileNumber].LastIndexOf('.')]}_sv.mem";
    compiledFile = File.CreateText(compiledFilePath);
    output = Regex.Replace(output, @"^.*?\r?\n", "");
    output = Regex.Replace(output, @"^.*?\s", "", RegexOptions.Multiline);
    compiledFile.Write(output);
    compiledFile.Flush();
}

void WriteConfigFile()
{
    var configFile = File.CreateText(configFilePath);
    foreach (var config in configSettings)
    {
        configFile.WriteLine(config.Key + "=" + config.Value);
    }
    configFile.Flush();
    configFile.Close();
}