module cp.languages.d;

import std.path: buildPath, dirName;
import std.file : exists, timeLastModified;
import std.process : executeShell, Config;
import std.exception : enforce;
import std.stdio: toFile;
import std.conv : to;
import std.algorithm : among;

import cp.session;
import cp.languages.language;
import cp.puzzles.puzzle;
import cp.communicationchannel;

class LanguageD: IfLanguage
{
    private IfSession _session;
    
    this(IfSession session)
    {
        assert(session !is null);
        _session = session;
    }
    
    void createPuzzle(string folder, Puzzle puzzle)
    {
        auto sc = new SourceCode();
        sc.addLine("import std;");
        sc.addEmptyLine();
        sc.addLine("void main()");
        sc.addLine("{");
        sc.increaseIndent();

        if (puzzle.metadata.gameLoop)
        {
            sc.addLine("while(true)");
            sc.addLine("{");
            sc.increaseIndent();
        }
        
        foreach(i, p; puzzle.inputParameters)
        {
            if (p.lengthRef != "")
            {
                sc.addLine("foreach (n; 0.." ~ p.lengthRef ~ ")");
                sc.addLine("{");
                sc.increaseIndent();
            }
            else if (p.length > 1)
            {
                sc.addLine("foreach (n; 0.." ~ p.length.to!string ~ ")");
                sc.addLine("{");
                sc.increaseIndent();
            }
            
            if (p.type == "string")
            {
                sc.addLine("string " ~ p.name ~ " = readln.strip;");
            }
            else if (p.type.among("int", "uint", "long", "ulong"))
            {
                sc.addLine(p.type ~ " " ~ p.name ~ " = to!" ~ p.type ~ "(readln.strip);");
            }
            
            if (p.lengthRef != "" || p.length > 1)
            {
                sc.decreaseIndent();
                sc.addLine("}");
                sc.addEmptyLine();
            }
            else
            {
                if (i == puzzle.inputParameters.length -1)
                    sc.addEmptyLine();
            }
        }
        
        sc.addLine("// Implement logic here");
        sc.addEmptyLine();
        sc.addLine("stdout.flush();");
        
        if (puzzle.metadata.gameLoop)
        {
            sc.decreaseIndent();
            sc.addLine("}");
        }
        
        sc.decreaseIndent();
        sc.addLine("}");
        
        string sourceFilePath = buildPath(folder, "app.d");
        toFile(sc.content, sourceFilePath);
        _session.logger.gameInfo("File created: " ~ sourceFilePath);
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
            _session.logger.gameInfo("Compiling " ~ sourceFilePath);
            
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
            _session.logger.gameInfo("Compiling not needed, actual executable existing.");
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
