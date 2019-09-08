module cp.tasks.playpuzzle;

import std.getopt;
import std.exception : enforce;

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
            usage : "puzz play PUZZLE_NAME [--language LANGUAGE] [--compiler COMPILER] [--force] [",
            example : "puzz play onboarding",
            arguments : [
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
        enforce!ArgumentMissingException(args.length > 0, "Puzzle name");

        string puzzleName = args[0];
        string languageName = "d";
        string compiler = "dmd";
        bool recompilation;

        // Dummy for getopt
        args = ["."] ~ args[1..$];

        getopt(args,
            "language|l", &languageName,
            "compiler|c", &compiler,
            "force|f", &recompilation);

        // Todo validate parameters

        Kernel.getForSession(_session).puzzleRuntime.playPuzzle(
            puzzleName, languageName, compiler, recompilation);
    }
}
