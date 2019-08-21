module cp.languages.d;

import std.path: buildPath, dirName;
import std.file : write, exists, timeLastModified;
import std.process : executeShell, Config;
import std.exception : enforce;
import std.stdio : writeln;

import cp.languages.language;
import cp.puzzles.puzzle;
import cp.communicationchannel;

class LanguageD: IfLanguage
{
    void createPuzzle(string folder, Puzzle puzzle)
    {
        string content = "import std;\n\nvoid main()\n{\n";
        
        if (puzzle.metadata.gameLoop)
        {
            content ~= "    while(true)\n    {\n";
        }
        
        foreach(p; puzzle.inputParameters)
        {
            if (puzzle.metadata.gameLoop)
            {
                content ~= "    ";
            }
            
            if (p.type == "string")
            {
                content ~= "    string " ~ p.name 
                    ~ " = readln.strip;\n";
            }
            else if (p.type == "int")
            {
                content  ~= "    int " ~ p.name 
                    ~ " = to!int(readln.strip);\n";
            }
        }
        
        if (puzzle.metadata.gameLoop)
        {
            content ~= "    }\n";
        }
        
        content ~= "}\n";
        
        string sourceFilePath = buildPath(folder, "app.d");
        write(sourceFilePath, content);
        writeln("File created: ", sourceFilePath);
    }
    
    IfCommunicationChannel startSolver(string folder, 
        Puzzle puzzle, string compiler, bool forceRecompilation)
    {
        string sourceFilePath = buildPath(folder, "app.d");
        enforce(exists(sourceFilePath), "File not found " ~ sourceFilePath);
        
        version(Windows)
        {
            string executableFilePath = buildPath(folder, "app.exe");
        }
        else
        {
            string executableFilePath = buildPath(folder, "app");
        }
        
        if (forceRecompilation || needCompilation(sourceFilePath, executableFilePath))
        {
            writeln("Compiling " ~ sourceFilePath);
            
            switch (compiler)
            {
                case "dmd":
                    compileDmd(sourceFilePath, executableFilePath);
                    break;
                case "ldc":
                case "ldc2":
                    compileLdc(sourceFilePath, executableFilePath);
                    break;
                default:
                    throw new Exception("Unknown compiler " ~ compiler);
            }
        }
        else 
        {
            writeln("Compiling not needed, actual executable existing.");
        }
        return new StdioChannel(executableFilePath);
    }
    
    private bool needCompilation(string sourceFilePath, string executableFilePath)
    {
        return !exists(executableFilePath) ||
            timeLastModified(executableFilePath) < timeLastModified(sourceFilePath);
    }
    
    private void compileDmd(string filePath, string executableFilePath)
    {
        auto o = executeShell("dmd " ~ filePath ~ " -of=" ~ executableFilePath ~ " -g", null, 
            Config.none, size_t.max, filePath.dirName);
         
        enforce(o.status == 0, o.output);
    }
    
    private void compileLdc(string filePath, string executableFilePath)
    {
        auto o = executeShell("ldc2 " ~ filePath ~ " -of=" ~ executableFilePath, null, 
            Config.none, size_t.max, filePath.dirName);
         
        enforce(o.status == 0, o.output);
    }
}
