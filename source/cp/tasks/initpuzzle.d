module cp.tasks.initpuzzle;

import std.getopt;
import std.exception : enforce;

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
            usage : "puzz init PUZZLE_NAME [--language LANGUAGE] [--force]",
            example : "puzz init onboarding",
            arguments : [
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
        enforce!ArgumentMissingException(args.length > 0, "Puzzle name");

        string puzzleName = args[0];
        string languageName = "d";
        bool forceRecreation;

        // Dummy for getopt
        args = ["."] ~ args[1..$];

        getopt(args,
            "language|l", &languageName,
            "force|f", &forceRecreation);

        // Todo validate parameters

        Kernel.getForSession(_session).puzzleRuntime.initPuzzle(
            puzzleName, languageName, forceRecreation);
    }
}
