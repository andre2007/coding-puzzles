module cp.tasks.task;

import cp.session;

struct TaskArgument
{
    string argument;
    string description;
}

struct TaskDescription
{
    string command;
    string description;
    string usage;
    string example;
    TaskArgument[] arguments;
}

interface IfTask
{
    @property TaskDescription taskDescription();
    void execute(string[] args);
}

IfTask[] getTasks(IfSession session)
{
    import cp.tasks.initpuzzle : InitPuzzleTask;
    import cp.tasks.playpuzzle : PlayPuzzleTask;
    import cp.tasks.listpuzzles : ListPuzzlesTask;

    return [cast(IfTask) new InitPuzzleTask(session),
            cast(IfTask) new PlayPuzzleTask(session),
            cast(IfTask) new ListPuzzlesTask(session)];
}

class ArgumentMissingException : Exception
{
    this(string argument, string file = __FILE__, size_t line = __LINE__) {
        super("Mandatory argument " ~ argument ~ " missing", file, line);
    }
}