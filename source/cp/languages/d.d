module cp.languages.d;

import std.path: buildPath, dirName;
import std.file : exists, timeLastModified;
import std.process : executeShell, Config;
import std.exception : enforce;
import std.stdio: toFile;
import std.conv : to, text;
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
    
    IfCommunicationChannel startSolver(string folder, 
        Puzzle puzzle, string compiler, bool forceRecompilation)
    {
        return new StartSolver(_session).execute(folder, puzzle, compiler, forceRecompilation);
    }
    
    void createPuzzle(string folder, Puzzle puzzle)
    {
        new CreatePuzzle(_session).execute(folder, puzzle);
    } 
}

private class StartSolver
{
    private IfSession _session;
    
    this(IfSession session)
    {
        assert(session !is null);
        _session = session;
    }
    
    IfCommunicationChannel execute(string folder, 
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

private class CreatePuzzle
{
    private IfSession _session;
    private SourceCode _sc;
    
    this(IfSession session)
    {
        assert(session !is null);
        _session = session;
    }
    
    private bool hasJoins(Parameter[] parameters)
    {
        foreach(parameter; parameters)
        {
            if (parameter.join)
                return true;
            else if (parameter.isComplex)
                return hasJoins(parameter.fields);
        }
        
        return false;
    }
    
    void execute(string folder, Puzzle puzzle)
    {      
        bool hasJoins = hasJoins(puzzle.inputParameters);
        
        _sc = new SourceCode();
        _sc.addLine("import std;");
        _sc.addEmptyLine();
        _sc.addLine("void main()");
        _sc.addLine("{");
        _sc.increaseIndent();
        
        if (hasJoins)
        {
            _sc.addLine("string[] inputs;");
        }

        if (puzzle.metadata.gameLoop)
        {
            _sc.addLine("while(true)");
            _sc.addLine("{");
            _sc.increaseIndent();
        }
        
        processParameters(puzzle.inputParameters);
        
        _sc.addLine("// Implement logic here");
        _sc.addEmptyLine();
        _sc.addLine("stdout.flush();");
        
        if (puzzle.metadata.gameLoop)
        {
            _sc.decreaseIndent();
            _sc.addLine("}");
        }
        
        _sc.decreaseIndent();
        _sc.addLine("}");
        
        string sourceFilePath = buildPath(folder, "app.d");
        toFile(_sc.content, sourceFilePath);
        _session.logger.gameInfo("File created: " ~ sourceFilePath);
    }
    
    private void processParameters(Parameter[] parameters)
    {
        bool isJoinedField;
        int joinIdx;
        
        foreach(i, p; parameters)
        {
            if (p.lengthRef != "" || p.length > 1)
            {
                if (p.join)
                {
                    _sc.addLine(`inputs = readln.strip.split("` ~ p.joinSeparator ~ `");`);
                    _sc.addLine("foreach (input; inputs)");
                    _sc.addLine("{");
                    _sc.increaseIndent();
                }
                else
                {
                    if (p.lengthRef != "")
                    {
                        _sc.addLine("foreach (n; 0.." ~ p.lengthRef ~ ")");
                        _sc.addLine("{");
                        _sc.increaseIndent();
                    }
                    else if (p.length > 1)
                    {
                        _sc.addLine("foreach (n; 0.." ~ p.length.to!string ~ ")");
                        _sc.addLine("{");
                        _sc.increaseIndent();
                    }
                    
                    if (p.type == "string")
                    {
                        _sc.addLine("string " ~ p.name ~ " = readln.strip;");
                    }
                    else if (p.type.among("int", "uint", "long", "ulong"))
                    {
                        _sc.addLine(p.type ~ " " ~ p.name ~ " = to!" ~ p.type ~ "(readln.strip);");
                    }
                    else if (p.isComplex)
                    {
                        processParameters(p.fields);
                    }
                }

                _sc.decreaseIndent();
                _sc.addLine("}");
                _sc.addEmptyLine();
                
                isJoinedField = false;
            }
            else
            {
                if (p.join && !isJoinedField)
                {
                    joinIdx = 0;
                    _sc.addLine(`inputs = readln.strip.split("` ~ p.joinSeparator ~ `");`);
                }
                
                if (p.join || isJoinedField)
                {
                    if (p.type == "string")
                    {
                        _sc.addLine("string " ~ p.name ~ " = inputs[" ~ joinIdx.text ~ "];");
                    }
                    else if (p.type.among("int", "uint", "long", "ulong"))
                    {
                        _sc.addLine(p.type ~ " " ~ p.name ~ " = to!" ~ p.type ~ "(inputs[" ~ joinIdx.text ~ "]);");
                    }
                    joinIdx += 1;
                }
                else
                {
                    if (p.type == "string")
                    {
                        _sc.addLine("string " ~ p.name ~ " = readln.strip;");
                    }
                    else if (p.type.among("int", "uint", "long", "ulong"))
                    {
                        _sc.addLine(p.type ~ " " ~ p.name ~ " = to!" ~ p.type ~ "(readln.strip);");
                    }
                    else if (p.isComplex)
                    {
                        processParameters(p.fields);
                    }
                }
                
                if (i == parameters.length -1)
                    _sc.addEmptyLine();
                    
                isJoinedField = p.join;
            }
        }
    }
}
