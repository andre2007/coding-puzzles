module cp.puzzles.puzzle;

import std.exception : enforce;
import std.algorithm;
import std.traits : hasUDA, getUDAs, isArray;

import cp.session;
import cp.communicationchannel;

enum Testcase;

struct Counter
{
    size_t value;
}

struct Parameter
{
    string name;
    string type;
    size_t counter;
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
            alias field = __traits(getMember, input, fieldName);
            
            static if(is(typeof(__traits(getMember,input, fieldName)) == int) || is(typeof(__traits(getMember,input, fieldName)) == long))
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
            else static if (isArray!(typeof(field)))
            {
                _session.logger.gameDebug("Sent array input '" ~ fieldName);
                
                static if(is(BaseTypeOf!(typeof(field)) == int) || is(BaseTypeOf!(typeof(field)) == long))
                {
                    foreach(i; __traits(getMember, input, fieldName))
                    {
                        string value = to!string(i);
                        _session.logger.gameDebug("  Sent value '" ~ value ~ "'");
                        _communicationChannel.sentData(value);
                    }

                }
                else static if(is(BaseTypeOf!(typeof(field)) == string))
                {
                    foreach(value; __traits(getMember, input, fieldName))
                    {
                        _session.logger.gameDebug("  Sent value '" ~ value ~ "'");
                        _communicationChannel.sentData(value);
                    }
                }
                else
                {
                    static assert(false, "Unsupported type: " ~ typeid(typeof(field)));
                }
            }
            else
            {
                static assert(false, "Unsupported type: " ~ typeid(typeof(field)));
            }
        }}

        _communicationChannel.flush();
        
        import core.thread: Thread;
        import core.time: msecs;
        Thread.sleep(200.msecs);

        Output output;

        static foreach(fieldName; __traits(allMembers, Output))
        {{
            static if(is(typeof(__traits(getMember, output, fieldName)) == int) || is(typeof(__traits(getMember, output, fieldName)) == long))
            {
                string value = _communicationChannel.receiveData();
                _session.logger.gameDebug("Receive output '" ~ fieldName ~ "' value '" ~ value ~ "'");
                __traits(getMember, output, fieldName) = to!(typeof(__traits(getMember, output, fieldName)))(value);
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

Puzzle[] getPuzzles()
{
    return _puzzles;
}

bool hasPuzzle(string puzzleName)
{
    return _puzzles.canFind!(p => p.metadata.name == puzzleName);
}

Puzzle getPuzzle(string puzzleName)
{
    foreach(p; _puzzles)
    {
        if (p.metadata.name == puzzleName)
            return p;
    }
    throw new Exception("Puzzle not found '" ~ puzzleName ~ "'");
}

template BaseTypeOf(T) {
    static if (is(T : U[], U))
        alias BaseTypeOf = BaseTypeOf!(U);
    else
        alias BaseTypeOf = T;
}

Parameter[] getParameters(T)()
{
    import std.traits : isStaticArray, isDynamicArray;

    Parameter[] results;
    
    static foreach(fieldName; __traits(allMembers, T))
    {{
        alias field = __traits(getMember, T, fieldName);

        static if(is(typeof(field) == int))
        {
            results ~= Parameter(fieldName, "int" , 1);
        } 
        else static if(is(typeof(field) == string))
        {
            results ~= Parameter(fieldName, "string", 1);
        }
        else static if(isStaticArray!(typeof(field)))
        {
            static if(is(BaseTypeOf!(typeof(field)) == int))
            {
                results ~= Parameter(fieldName, "int", field.length);
            }
            else static if(is(BaseTypeOf!(typeof(field)) == string))
            {
                results ~= Parameter(fieldName, "string", field.length);
            }
        }
        else static if(isDynamicArray!(typeof(field)))
        {
            size_t counter = 1;
            
            static if(hasUDA!(field,Counter))
            {
                counter = getUDAs!(field, Counter)[0].value;
            }
            
            static if(is(BaseTypeOf!(typeof(field)) == int))
            {
                results ~= Parameter(fieldName, "int", counter);
            }
            else static if(is(BaseTypeOf!(typeof(field)) == string))
            {
                results ~= Parameter(fieldName, "string", counter);
            }
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


