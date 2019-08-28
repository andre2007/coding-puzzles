module cp.base.logging;

interface IfLogger
{
    void setDebug(bool debug_);
    void gameInfo(string s);
    void gameDebug(string s);
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
        writeln("G: ", s);
    }
    
    void gameDebug(string s)
    {
        if (_debug)
           writeln(" __ ", s);  
    }
    
    void puzzleOut(string s)
    {
        writeln("puzzleOut: ", s);
    }
    
    void puzzleErr(string s)
    {
        writeln("puzzleErr: ", s);
    }
}