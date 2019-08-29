module cp.communicationchannel;

import std.process;
import std.array : join;
import std.file : exists;
import std.exception : enforce;
import std.string: strip;

interface IfCommunicationChannel
{
    void openChannel();
    void sentData(string data);
    void flush();
    string receiveData();
    string receiveDebug();
    void closeChannel();
}

class StdioChannel : IfCommunicationChannel
{
    private ProcessPipes _processPipes;
    private string _executablePath;
    
    this(string executablePath)
    {
        enforce(exists(executablePath), 
            "File not exists " ~ executablePath);
        _executablePath = executablePath;
    }
    
    void openChannel()
    {
        _processPipes = pipeShell(_executablePath, Redirect.all);
    }
    
    void sentData(string data)
    {
        _processPipes.stdin.writeln(data);
    }
    
    void flush()
    {
        _processPipes.stdin.flush();
    }
    
    string receiveData()
    {
        return (_processPipes.stdout.size == 0) ? "" : _processPipes.stdout.readln().strip;
    }
    
    string receiveDebug()
    {
        string[] output;
        foreach (line; _processPipes.stderr.byLine)
            output ~= line.idup;
        return output.join("\n");
    }
    
    void closeChannel()
    {       
        // This logic avoid the druntime MessageBox (Win api) if exception occurs
        _processPipes.stdin.close;
        //_processPipes.stderr.byLineCopy.writeln;
        try
        {
            _processPipes.pid.kill; 
            _processPipes.pid.wait;
        } catch (Throwable) { }
    }
}
