module cp.cmdline;

import std.stdio;

import cp.session;
import cp.puzzles.puzzle;
import cp.tasks.task;

class CommandLine
{
    private IfTask[] _tasks;
    
    this(IfSession session)
    {
        _tasks = getTasks(session);
    }
    
    int execute(string[] args)
    {
        if (args.length == 0)
        {
            writeln("No command provided");
            return 1;
        }
        
        try
        {
            executeTask(args);
        }
        catch (Exception e)
        {
            writeln("Failed: " ~ e.msg);
            return 1;
        }

        return 0;
    }
    
    void executeTask(string[] args)
    {
        foreach(task; _tasks)
        {
            if (task.taskDescription.command == args[0])
            {
                task.execute(args[1..$]);
                return;
            }
        }
        throw new Exception("Unknown command " ~ args[0]);
    }
}
