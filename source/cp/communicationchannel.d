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
        _processPipes.stdin.write(data);
    }
    
    void flush()
    {
        _processPipes.stdin.flush();
    }
    
    string receiveData()
    {
        if (_processPipes.stdout.size == 0)
        {
            return "";
        }
        else
        {
            auto buffer = new char[1024];
            string result;
            
            do
            {
                auto data = _processPipes.stdout.rawRead(buffer);
                result ~= data.idup.strip;
            } while (_processPipes.stdout.size > 0);
            
            return result;
        }
    }
    
    string receiveDebug()
    {
        if (_processPipes.stderr.size == 0)
        {
            return "";
        }
        else
        {
            auto buffer = new char[1024];
            string result;
            
            do
            {
                auto data = _processPipes.stderr.rawRead(buffer);
                result ~= data.idup.strip;
            } while (_processPipes.stderr.size > 0);
            
            return result;
        }
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
