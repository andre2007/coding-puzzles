module cp.puzzles.puzzle;

import std.exception : enforce;
import std.algorithm;

import cp.session;
import cp.communicationchannel;

enum Testcase;

struct Parameter
{
    string name;
    string type;
}

struct PuzzleMetadata
{
    string name;
    string description;
    bool gameLoop;
}

mixin template PuzzleBase(Input, Output)
{
    import std.conv : to;
    
    import cp.puzzles.puzzle : getParameters, getTestcases, Testcase;
    import cp.communicationchannel;
    import cp.session;
    
    private IfCommunicationChannel _communicationChannel;
    private IfSession _session;
    
    private static this()
    {
        static Object create()
        {
            mixin("return new " ~ typeof(this).stringof ~ "();");
        }
        
        void testcase(Object o, string name)
        {
            mixin(_choice(_members!(typeof(this), Testcase)));
        }
        
        void setCommunicationChannel(Object o, IfCommunicationChannel communicationChannel)
        {
            assert(communicationChannel !is null);
            mixin("auto testObject = cast(" ~ typeof(this).stringof ~ ") o;\n   testObject._communicationChannel=communicationChannel;");
        }
        
        void setSession(Object o, IfSession session)
        {
            assert(session !is null);
            mixin("auto testObject = cast(" ~ typeof(this).stringof ~ ") o;\n   testObject._session=session;");
        }
        
        Puzzle puzzle;
        puzzle.name = this.classinfo.name;
        puzzle.create = &create;
        puzzle.testcase = &testcase;
        puzzle.testcases = getTestcases!(typeof(this))();
        puzzle.inputParameters = getParameters!Input();
        puzzle.outputParameters = getParameters!Output();
        puzzle.setCommunicationChannel = &setCommunicationChannel;
        puzzle.setSession= &setSession;

        static if (__traits(hasMember, typeof(this), "metadata"))
        {
            puzzle.metadata = __traits(getMember, typeof(this), "metadata")();
        }
        
        registerPuzzle(puzzle);
    }

    struct PlayResult
    {
        Output output;
        alias output this;

        this(Output output)
        {
            this.output = output;
        }

        void validate(Output expected)
        {
            if (expected != output)
            {
                throw new Exception("Validation failed");
            }
        }
        
        void validate(A...)(A a)
            if (a.length <= __traits(allMembers, Output).length)
        {
            Output expected;
            static foreach(i, fieldName; __traits(allMembers, Output))
            {
                __traits(getMember, expected, fieldName) = a[i];
            }
            validate(expected);
        }
    }

    PlayResult play(A...)(A a)
        if (a.length <= __traits(allMembers, Input).length)
    {
        Input input;
        static foreach(i, fieldName; __traits(allMembers, Input))
        {
            __traits(getMember, input, fieldName) = a[i];
        }
        return play(input);
    }

    PlayResult play(Input input)
    {
        static foreach(fieldName; __traits(allMembers, Input))
        {{
            static if(is(typeof(__traits(getMember,input, fieldName)) == int))
            {
                string value = to!string(__traits(getMember, input, fieldName));
                _session.logger.gameDebug("Sent input '" ~ fieldName ~ "' value '" ~ value ~ "'");
                _communicationChannel.sentData(value);
            } 
            else static if(is(typeof(__traits(getMember, input, fieldName)) == string))
            {
                string value = __traits(getMember, input, fieldName);
                _session.logger.gameDebug("Sent input '" ~ fieldName ~ "' value '" ~ value ~ "'");
                _communicationChannel.sentData(value);
            }
        }}

        _communicationChannel.flush();
        
        import core.thread: Thread;
        import core.time: msecs;
        Thread.sleep(200.msecs);

        Output output;

        static foreach(fieldName; __traits(allMembers, Output))
        {{
            static if(is(typeof(__traits(getMember, output, fieldName)) == int))
            {
                string value = _communicationChannel.receiveData();
                _session.logger.gameDebug("Receive output '" ~ fieldName ~ "' value '" ~ value ~ "'");
                __traits(getMember, output, fieldName) = to!int(value);
            } 
            else static if(is(typeof(__traits(getMember, output, fieldName)) == string))
            {
                string value = _communicationChannel.receiveData();
                _session.logger.gameDebug("Receive output '" ~ fieldName ~ "' value '" ~ value ~ "'");
                __traits(getMember, output, fieldName) = value;
            }
        }}

        return PlayResult(output);
    }
    
    void validate(Output actual, Output expected)
    {
        if (expected != actual)
        {
            throw new Exception("Validation failed");
        }
    }
    
    private static string _choice(in string[] memberFunctions)
    {
        string block = "auto testObject = cast(" ~ typeof(this).stringof ~ ") o;\n";

        block ~= "switch (name)\n{\n";
        foreach (memberFunction; memberFunctions)
            block ~= `case "` ~ memberFunction ~ `": testObject.` ~ memberFunction ~ "(); break;\n";
        block ~= "default: break;\n}\n";
        return block;
    }
    
    template _members(T, alias attribute)
    {
        static string[] helper()
        {
            import std.meta : AliasSeq;
            import std.traits : hasUDA;

            string[] members;

            foreach (name; __traits(allMembers, T))
            {
                static if (__traits(compiles, __traits(getMember, T, name)))
                {
                    alias member = AliasSeq!(__traits(getMember, T, name));

                    static if (__traits(compiles, hasUDA!(member, attribute)))
                    {
                        static if (hasUDA!(member, attribute))
                            members ~= name;
                    }
                }
            }
            return members;
        }

        enum _members = helper;
    }
}

struct Puzzle
{
    string name;
    Object function() create;
    void delegate(Object o, string test) testcase;
    void delegate(Object o, IfCommunicationChannel communicationChannel) setCommunicationChannel;
    void delegate(Object o, IfSession session) setSession;
    string[] testcases;
    Parameter[] inputParameters;
    Parameter[] outputParameters;
    PuzzleMetadata metadata;
    
}

private Puzzle[] _puzzles;

void registerPuzzle(Puzzle p)
{
   _puzzles ~= p;
}

/*

IfPuzzle[] getPuzzles()
{
    return _puzzles;
}

bool hasPuzzle(string puzzleName)
{
    return _puzzles.canFind!(p => p.metadata.name == puzzleName);
}

*/

Puzzle getPuzzle(string puzzleName)
{
    foreach(p; _puzzles)
    {
        if (p.metadata.name == puzzleName)
            return p;
    }
    throw new Exception("Puzzle not found '" ~ puzzleName ~ "'");
}

Parameter[] getParameters(T)()
{
    Parameter[] results;
    
    static foreach(fieldName; __traits(allMembers, T))
    {{
        alias field = __traits(getMember, T, fieldName);
        
        static if(is(typeof(field) == int))
        {
            results ~= Parameter(fieldName, "int");
        } 
        else static if(is(typeof(field) == string))
        {
            results ~= Parameter(fieldName, "string");
        }
    }}
    return results;
}

string[] getTestcases(T)()
{
    import std.traits: hasUDA;

    string[] results;
    static foreach(fieldName; __traits(allMembers, T))
    {
        static if(hasUDA!(__traits(getMember, T, fieldName), Testcase))
        {
            results ~= fieldName;
        }
    }
    return results;
}


