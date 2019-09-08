module cp.base.logging;

interface IfLogger
{
    void setDebug(bool debug_);
    void gameInfo(string s);
    void gameDebug(string s);
    void puzzleIn(string s);
    void puzzleOut(string s);
    void puzzleErr(string s);
}

class Logger : IfLogger
{
    private import std.stdio: writeln;
    
    private bool _debug;
    
    void setDebug(bool debug_)
    {
        _debug = debug_;
    }
    
    void gameInfo(string s)
    {
        writeln(s);
    }
    
    void gameDebug(string s)
    {
        if (_debug)
           writeln("  __ ", s);  
    }
    
    void puzzleIn(string s)
    {
        if (_debug)
            writeln("  in >> ", s);
    }
    
    void puzzleOut(string s)
    {
        if (_debug)
            writeln("  out >> ", s);
    }
    
    void puzzleErr(string s)
    {
        import std.ascii : newline;
        import std.array : split;
        
        foreach(line; s.split(newline))
        {
            writeln("  err >> : ", line);
        }
    }
}