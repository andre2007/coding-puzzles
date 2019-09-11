module cp.tests.common;

import core.thread : Fiber;

import std.algorithm : countUntil;
import std.exception: enforce;
import std.string: strip;

import cp.kernel;
import cp.communicationchannel;

enum FiberStrategy {none, callOnFlush, yieldOnFlush}

class DummyFile
{
    private string _buffer;
    private Fiber _fiber;
    private FiberStrategy _fiberStrategy;
    
    this(Fiber fiber, FiberStrategy fiberStrategy)
    {
        _fiber = fiber;
        _fiberStrategy = fiberStrategy;
    }
   
    @property size_t size()
    {
        return _buffer.length;
    }
    
    string readln() 
    { 
        auto p = _buffer.countUntil("\n");
        enforce(p != -1, "Buffer is empty");
        string result = _buffer[0..p + 1];
        _buffer = _buffer[p + 1..$];
        return result; 
    }
    
    void write(string s) 
    {
        _buffer = _buffer ~ s;
    }
    
    void writeln(string s) 
    {
        write(s ~ "\n");
    }
    
    void flush()
    {
        switch (_fiberStrategy)
        {
            case FiberStrategy.callOnFlush:
                _fiber.call();
                break;
            case FiberStrategy.yieldOnFlush:
                _fiber.yield();
                break;
            default:
        }
    }
    
    char[] rawRead(char[] buffer)
    {
        char[] result = new char[](buffer.length);
        
        result = _buffer.dup;
        
        if (buffer.length > _buffer.length)
        {
            _buffer = "";
        }
        else
        {
            _buffer = _buffer[buffer.length..$];
        }

        return result;
    }
}

alias TestDelegate = void delegate (DummyFile i, DummyFile o, DummyFile e);

void executeTestcase(string puzzleName, string testcase, TestDelegate testDelegate)
{
    class DummyCommunicationChannel : IfCommunicationChannel
    {
        private Fiber _fiber;
        private DummyFile _i;
        private DummyFile _o;
        private DummyFile _e;

        void openChannel()
        {
            _fiber = new Fiber(delegate void() {
                testDelegate(_i, _o, _e);
            });
            
            _i = new DummyFile(_fiber, FiberStrategy.callOnFlush);
            _o = new DummyFile(_fiber, FiberStrategy.yieldOnFlush);
            _e = new DummyFile(_fiber, FiberStrategy.none);
        }
        
        void sentData(string data)
        {
            _i.write(data);
        }
        
        void flush()
        {
            _i.flush();
            
            //_fiber.call();
        }
        
        string receiveData()
        {  
            if (_o.size == 0)
            {
                return "";
            }
            else
            {
                auto buffer = new char[1024];
                string result;
                
                do
                {
                    auto data = _o.rawRead(buffer);
                    result ~= data.idup.strip;
                } while (_o.size > 0);
                
                return result;
            }
        }
        
        string receiveDebug()
        { 
            return "";
        }
        
        void closeChannel()
        {
        
        }
    }
    
    auto kernel = Kernel.create();
    kernel.session.logger.setDebug(true);
    auto dummyChannel = new DummyCommunicationChannel();
    kernel.puzzleRuntime.playPuzzle(puzzleName, [testcase], dummyChannel); 
}
