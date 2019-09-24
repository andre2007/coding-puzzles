module cp.puzzles.puzzle;

import std.algorithm;
import std.array : split;
import std.traits : hasUDA, getUDAs, isArray;

import cp.session;
import cp.communicationchannel;

struct Testcase
{
    string name;
}

struct Join
{
    string separator = " ";
}

struct Length
{
    size_t value;
}

struct LengthRef
{
    string name;
}

struct TestcaseMetadata
{
    string name;
    string description;
}

struct Parameter
{
    string name;
    string type;
    size_t length;
    string lengthRef;
    bool isComplex;
    Parameter[] fields;
    bool join;
    string joinSeparator;
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
    private OutputPropertyConfig[string] _outputPropertiesConfigMap;
    
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
        puzzle.className = this.classinfo.name;
        puzzle.create = &create;
        puzzle.executeTestcase = &testcase;
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

    struct OutputPropertyConfig
    {
        size_t length;
    }

    OutputPropertyConfig* outputProperty(string s)
    {
        if (s !in _outputPropertiesConfigMap)
        {
            _outputPropertiesConfigMap[s] = OutputPropertyConfig();
        }
        
        return s in _outputPropertiesConfigMap;
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
    
    private void sendData(T)(T t)
    {
        static foreach(fieldName; __traits(allMembers, T))
        {{
            alias field = __traits(getMember, t, fieldName);
            bool join;
            string joinSeparator;
            
            static if (hasUDA!(__traits(getMember, T, fieldName), Join ))
            {
                join = true;
              
                static if (is (getUDAs!(__traits(getMember, T, fieldName), Join)[0]))
                {
                    joinSeparator = Join().separator;
                } else {
                    joinSeparator = getUDAs!(__traits(getMember, T, fieldName), Join)[0].separator;
                }
            }
            
            static if(is(typeof(field) == int) || is(typeof(field) == uint) ||
                is(typeof(field) == long) || is(typeof(field) == ulong))
            {
                string value = to!string(__traits(getMember, t, fieldName));
                _session.logger.puzzleIn("Sent input '" ~ fieldName ~ "' value '" ~ value ~ "'");
                if (join)
                    _communicationChannel.sentData(value ~ joinSeparator);
                else
                    _communicationChannel.sentData(value ~ "\n");
            } 
            else static if(is(typeof(field) == string))
            {
                string value = __traits(getMember, t, fieldName);
                _session.logger.puzzleIn("Sent input '" ~ fieldName ~ "' value '" ~ value ~ "'");
                if (join)
                    _communicationChannel.sentData(value ~ joinSeparator);
                else
                    _communicationChannel.sentData(value ~ "\n");
            }
            else static if (isArray!(typeof(field)))
            {
                _session.logger.puzzleIn("Sent array input '" ~ fieldName ~ "'");
                
                static if(is(BaseTypeOf!(typeof(field)) == int) || 
                    is(BaseTypeOf!(typeof(field)) == uint) ||
                    is(BaseTypeOf!(typeof(field)) == long) ||
                    is(BaseTypeOf!(typeof(field)) == ulong))
                {
                    foreach(i; __traits(getMember, t, fieldName))
                    {
                        string value = to!string(i);
                        _session.logger.puzzleIn("    '" ~ value ~ "'");
                        if (join)
                            _communicationChannel.sentData(value ~ joinSeparator);
                        else
                            _communicationChannel.sentData(value ~ "\n");
                    }
                    
                    if (join)
                        _communicationChannel.sentData("\n");

                }
                else static if(is(BaseTypeOf!(typeof(field)) == string))
                {
                    foreach(value; __traits(getMember, t, fieldName))
                    {
                        _session.logger.puzzleIn("    '" ~ value ~ "'");
                        if (join)
                            _communicationChannel.sentData(value ~ joinSeparator);
                        else
                            _communicationChannel.sentData(value ~ "\n");
                    }
                    
                    if (join)
                        _communicationChannel.sentData("\n");
                }
                else static if(is(BaseTypeOf!(typeof(field)) == struct))
                {
                    foreach(r; __traits(getMember, t, fieldName))
                    {
                        sendData(r);
                    }
                }
                else
                {
                    static assert(false, "Unsupported type: " ~ typeof(field).stringof);
                }
            }
            else
            {
                static assert(false, "Unsupported type: " ~ typeof(field).stringof);
            }
        }}
    }
    
    private T receiveOutput(T)()
    {
        T t;
        
        bool isJoinedField;
        string[] joinBuffer;
        
        static foreach(fieldName; __traits(allMembers, T))
        {{
            alias field = __traits(getMember, t, fieldName);
            bool join;
            string joinSeparator;
            
            static if (hasUDA!(__traits(getMember, T, fieldName), Join ))
            {
                join = true;
              
                static if (is (getUDAs!(__traits(getMember, T, fieldName), Join)[0]))
                {
                    joinSeparator = Join().separator;
                } else {
                    joinSeparator = getUDAs!(__traits(getMember, T, fieldName), Join)[0].separator;
                }
            }
            
            static if(is(typeof(field) == int) || is(typeof(field) == uint) ||
                is(typeof(field) == long) || is(typeof(field) == ulong))
            {
                if (join && !isJoinedField)
                {
                    string value = _communicationChannel.receiveData();
                    _session.logger.puzzleOut("Receive output '" ~ fieldName ~ "' value '" ~ value ~ "'");
                    enforce(value != "", "Cannot read output for field '" ~ fieldName ~ "'");
                    
                    joinBuffer = value.split(joinSeparator);
                    __traits(getMember, t, fieldName) = to!(typeof(__traits(getMember, t, fieldName)))(joinBuffer[0]);
                    joinBuffer = joinBuffer[1..$];
                }
                else if (isJoinedField)
                {
                    __traits(getMember, t, fieldName) = to!(typeof(__traits(getMember, t, fieldName)))(joinBuffer[0]);
                    joinBuffer = joinBuffer[1..$];
                }
                else
                {
                    string value = _communicationChannel.receiveData();
                    _session.logger.puzzleOut("Receive output '" ~ fieldName ~ "' value '" ~ value ~ "'");
                    enforce(value != "", "Cannot read output for field '" ~ fieldName ~ "'");
                    
                    __traits(getMember, t, fieldName) = to!(typeof(__traits(getMember, t, fieldName)))(value);
                }
            }
            else static if(is(typeof(field) == string))
            {
                string value = _communicationChannel.receiveData();
                _session.logger.puzzleOut("Receive output '" ~ fieldName ~ "' value '" ~ value ~ "'");
                enforce(value != "", "Cannot read output for field '" ~ fieldName ~ "'");
                __traits(getMember, t, fieldName) = value;
            }
            else static if (isArray!(typeof(field)))
            {
                static if(is(BaseTypeOf!(typeof(field)) == string))
                {
                    string[] values;

                    _session.logger.puzzleOut("Receive array output '" ~ fieldName ~ "', expected length " ~ outputProperty(fieldName).length.text);

                    foreach(n; 0..outputProperty(fieldName).length)
                    {
                        if (values.length == 0)
                        {
                             values = _communicationChannel.receiveData().split("\n").map!(s => s.strip).array;
                        }
                        
                        if (values.length > 0)
                        {
                            string value = values[0];
                            values = values[1..$];
                            _session.logger.puzzleOut("    '" ~ value ~ "'");
                            __traits(getMember, t, fieldName) ~= value;
                        }
                    }
                }
                else
                {
                    static assert(false, "Unsupported type: " ~ typeof(field).stringof);
                }
            }
            else
            {
                static assert(false, "Unsupported type: " ~ typeof(field).stringof);
            }
            
            isJoinedField = join;
        }}
        
        return t;
    }
        
    PlayResult play(Input input)
    {
        sendData(input);
        _communicationChannel.flush();

        import core.thread: Thread;
        import core.time: msecs;
        Thread.sleep(200.msecs);
        Output output = receiveOutput!Output();

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
    string className;
    Object function() create;
    void delegate(Object o, string test) executeTestcase;
    void delegate(Object o, IfCommunicationChannel communicationChannel) setCommunicationChannel;
    void delegate(Object o, IfSession session) setSession;
    TestcaseMetadata[] testcases;
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
        if (!puzzleName.canFind("."))
        {
            if (p.metadata.name.split(".")[$-1] == puzzleName)
                return p;
        }
        else
        {
            if (p.metadata.name == puzzleName)
                return p;
        }
    }
    throw new Exception("Puzzle not found '" ~ puzzleName ~ "'");
}

template BaseTypeOf(T) {
    static if (is(T : U[], U))
        alias BaseTypeOf = U;
    else
        alias BaseTypeOf = T;
}

Parameter[] getParameters(T)()
{
    import std.traits : isArray, isDynamicArray;

    Parameter[] results;
    
    static foreach(fieldName; __traits(allMembers, T))
    {{
        alias field = __traits(getMember, T, fieldName);

        Parameter parameter;
        parameter.name = fieldName;
        
        static if (hasUDA!(__traits(getMember, T, fieldName), Join ))
        {
            parameter.join = true;
          
            static if (is (getUDAs!(__traits(getMember, T, fieldName), Join)[0]))
            {
                parameter.joinSeparator = Join().separator;
            } else {
                parameter.joinSeparator = getUDAs!(__traits(getMember, T, fieldName), Join)[0].separator;
            }
        }

        static if(is(typeof(field) == int) || is(typeof(field) == uint) || is(typeof(field) == long) || is(typeof(field) == ulong) || is(typeof(field) == string))
        {
            parameter.type = typeof(field).stringof;
            parameter.length = 1;
        }
        else static if(isArray!(typeof(field)))
        {
            static if(isDynamicArray!(typeof(field)))
            {
                static if(hasUDA!(field, Length))
                {
                    parameter.length = getUDAs!(field, Length)[0].value;
                }
                else static if(hasUDA!(field, LengthRef))
                {
                    parameter.length = 0;
                    parameter.lengthRef = getUDAs!(field, LengthRef)[0].name;
                }
            }
            else
            {
                parameter.length = field.length;
            }
            
            static if(is(BaseTypeOf!(typeof(field)) == int) || is(BaseTypeOf!(typeof(field)) == uint) || is(BaseTypeOf!(typeof(field)) == long) || is(BaseTypeOf!(typeof(field)) == ulong) || is(BaseTypeOf!(typeof(field)) == string))
            {
                parameter.type = BaseTypeOf!(typeof(field)).stringof;
            }
            else static if(is(BaseTypeOf!(typeof(field)) == struct))
            {
                parameter.isComplex = true;
                parameter.fields = getParameters!(BaseTypeOf!(typeof(field)));
            }
            else
            {
                static assert(false, "Unsupported type: " ~ typeof(field).stringof);
            }
        }
        else
        {
            static assert(false, "Unsupported type: " ~ typeof(field).stringof);
        }
        
        results ~= parameter;
    }}
    return results;
}

TestcaseMetadata[] getTestcases(T)()
{
    TestcaseMetadata[] results;

    static foreach(fieldName; __traits(allMembers, T))
    {
        static if (hasUDA!(__traits(getMember, T, fieldName), Testcase ))
        {
          static if (is (getUDAs!(__traits(getMember, T, fieldName), Testcase)[0]))
          {
              results ~= TestcaseMetadata(fieldName, fieldName);
          } else {
              results ~= TestcaseMetadata(fieldName, getUDAs!(__traits(getMember, T, fieldName), Testcase)[0].name);
          }
        }
    }
    return results;
}


