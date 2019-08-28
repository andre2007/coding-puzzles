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
	import cp.tasks.initpuzzle;
	import cp.tasks.playpuzzle;
	import cp.tasks.listpuzzles;
	
	return [cast(IfTask) new InitPuzzleTask(session), 
			cast(IfTask) new PlayPuzzleTask(session), 
			cast(IfTask) new ListPuzzlesTask(session)];
}
