module cp.tasks.listpuzzles;

import std.getopt;
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
            arguments : [
                TaskArgument("output|o", "Format (formatted, json)")
            ]
        };
        return result;
    }

    this(IfSession session)
    {

    }

    void execute(string[] args)
    {
        string output;

        // Dummy for getopt
        args = ["."] ~ args;

        getopt(args,
            "output", &output);

        if (output == "json")
        {
            outputJson();
        }
        else
        {
            outputFormatted();
        }
    }

    private void outputFormatted()
    {
        writeln("Puzzles:\n");

        foreach(p; getPuzzles())
        {
            writeln("    " ~ p.metadata.name);
        }
    }

    private void outputJson()
    {
        import std.algorithm: map;
        import std.json;
        import std.array : array;

        JSONValue[] jsPuzzles = getPuzzles().map!(p => JSONValue([
            "name": p.metadata.name,
            "description": p.metadata.description])
        ).array;

        JSONValue root = JSONValue(["puzzles": JSONValue(jsPuzzles)]);
        writeln(root.toString());
    }
}
