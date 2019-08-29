module cp.tasks.listpuzzles;

import std.stdio : writeln;

import cp.session;
import cp.tasks.task;
import cp.puzzles.puzzle;

class ListPuzzlesTask: IfTask
{
	@property TaskDescription taskDescription()
	{
		TaskDescription result = {
			command : "list",
			description : "List puzzles",
			example : "puzz list",
			arguments : []
		};
		return result;
	}
	
	this(IfSession session)
	{
		
	}
	
	void execute(string[] args)
	{
		writeln("Puzzles:\n");
		
		foreach(p; getPuzzles())
		{
			writeln("    " ~ p.metadata.name);
		}
		
	}
}
