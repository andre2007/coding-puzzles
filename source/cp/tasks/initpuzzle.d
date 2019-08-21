module cp.tasks.initpuzzle;

import std.getopt;

import cp.kernel;
import cp.session;
import cp.tasks.task;
import cp.puzzles.puzzle;

class InitPuzzleTask: IfTask
{
	private IfSession _session;
	
	@property TaskDescription taskDescription()
	{
		TaskDescription result = {
			command : "init",
			description : "Init puzzle",
			example : "puzz init -p cg.easy.Onboarding",
			arguments : [
				TaskArgument("puzzle|p", "Puzzle"),
				TaskArgument("language|l", "Language (Default d)"),
				TaskArgument("force|f", "Recreate if already existing")
			]
		};
		return result;
	}
	
	this(IfSession session)
	{
		_session = session;
	}
	
	void execute(string[] args)
	{
		string puzzleName;
		string languageName = "d";
		bool forceRecreation;
		
		// Dummy for getopt
		args = ["."] ~ args;
		
		getopt(args,
			std.getopt.config.required,
			"puzzle|p", &puzzleName,
			"language|l", &languageName,
			"force|f", &forceRecreation);
		
		// Todo validate parameters
		
		Kernel.getForSession(_session).puzzleRuntime.initPuzzle(
			puzzleName, languageName, forceRecreation);
	}
}
