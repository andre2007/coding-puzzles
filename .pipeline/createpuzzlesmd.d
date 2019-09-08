/+ dub.sdl:
	name "createpuzzlesmd"
+/

import std.exception : enforce;
import std.stdio : writeln, toFile;
import std.process : execute;
import std.json;

void main(string[] args)
{
    enforce(args.length == 3, "Invalid arguments count");
    
    string puzzExecutableFilePath = args[1];
    string markdownFilePath = args[2];
    
    auto o = execute([puzzExecutableFilePath, "list", "--output", "json"]);
    enforce(o.status == 0, o.output);

    JSONValue jsRoot = parseJSON(o.output);
    string result = "Available puzzles: \n";
    foreach(jsPuzzle; jsRoot["puzzles"].array)
    {
        result ~= "- " ~ jsPuzzle["name"].str ~"\n\n  " ~ jsPuzzle["description"].str ~ "\n";
    }
    
    result.toFile(markdownFilePath);
}