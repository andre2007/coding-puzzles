module cp.languages.language;

import cp.session;
import cp.puzzles.puzzle;
import cp.communicationchannel;

interface IfLanguage
{
    void createPuzzle(string folder, Puzzle puzzle);
    
    IfCommunicationChannel startSolver(string folder, 
        Puzzle puzzle, string compiler, bool forceRecompilation);
}

IfLanguage getLanguage(IfSession session, string language)
{
    import cp.languages.d : LanguageD;
    
    switch(language)
    {
        case "d":
            return new LanguageD(session);
        default:
            throw new Exception("Unknown language " ~language);
    }
}

class SourceCode
{
    private string _content;
    private int _tabSize = 4;
    private string _indent;
    
    @property string content()
    {
        return _content;
    }
    
    void addLine(string s)
    {
        _content ~= _indent ~ s ~ "\n";
    }
    
    void addEmptyLine()
    {
        _content ~= "\n";
    }
    
    void increaseIndent()
    {
        import std.string : rightJustify;
        
        _indent = _indent.rightJustify(_indent.length + _tabSize);
    }
    
    void decreaseIndent()
    {
        if (_indent.length == 0)
            return;
            
        _indent = _indent[0..$ - _tabSize];
    }
    
}
