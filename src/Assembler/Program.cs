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
    configSettings.Add("addressWidth", "8");
    configSettings.Add("assemblerVersion", "DRisc");
    var configFile = File.CreateText(configFilePath);
    foreach (var config in configSettings)
    {
        configFile.WriteLine(config.Key + "=" + config.Value);
    }
    configFile.Flush();
}

List<string> fileNames = [];
string[] files = Directory.GetFiles(configSettings["searchFolder"], "*.*", SearchOption.TopDirectoryOnly);
foreach (string file in files)
{
    if (file.EndsWith(".dasm") || file.EndsWith(".txt"))
    {
        fileNames.Add(Path.GetFileName(file));
    }
}
Console.WriteLine("Choose a file to assemble: \n");
int fileNumber = 0;
foreach (string fileName in fileNames)
{
    Console.WriteLine(fileNumber + "-" + fileName);
    fileNumber++;
}
if (!int.TryParse(Console.ReadLine(), out fileNumber))
{
    Console.WriteLine("Invalid Number");
    return;
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
        output = DRiscAssembler.Assembler.Assemble(input, int.Parse(configSettings["bitWidth"]), int.Parse(configSettings["addressWidth"]));
    }
    else
    {
        output = RiscAssembler.Assembler.Assemble(input, int.Parse(configSettings["bitWidth"]), int.Parse(configSettings["addressWidth"]));
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
Console.ReadLine();