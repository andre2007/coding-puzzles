module cp.tasks.listpuzzles;

import cp.session;
import cp.tasks.task;

class ListPuzzlesTask: IfTask
{
	@property TaskDescription taskDescription()
	{
		TaskDescription result = {
			command : "list",
			description : "List puzzles",
			example : "puzz list -p cg.easy.Onboarding",
			arguments : []
		};
		return result;
	}
	
	this(IfSession session)
	{
		
	}
	
	void execute(string[] args)
	{
	}
}
