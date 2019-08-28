module cp.tasks.playpuzzle;

import std.getopt;

import cp.kernel;
import cp.session;
import cp.tasks.task;

class PlayPuzzleTask: IfTask
{
	private IfSession _session;
	
	@property TaskDescription taskDescription()
	{
		TaskDescription result = {
			command : "play",
			description : "Play puzzle",
			example : "puzz play -p cg.easy.Onboarding",
			arguments : [
				TaskArgument("puzzle|p", "Puzzle"),
				TaskArgument("language|l", "Language (Default d)"),
				TaskArgument("compiler|c", "Compiler (Default dmd)"),
                TaskArgument("force|f", "Force recompilation")
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
		string compiler = "dmd";
        bool recompilation;
		
		// Dummy for getopt
		args = ["."] ~ args;
		
		getopt(args,
			std.getopt.config.required,
			"puzzle|p", &puzzleName,
			"language|l", &languageName,
			"compiler|c", &compiler,
			"force|f", &recompilation);
		
		// Todo validate parameters
		
		Kernel.getForSession(_session).puzzleRuntime.playPuzzle(
			puzzleName, languageName, compiler, recompilation);
	}
}
