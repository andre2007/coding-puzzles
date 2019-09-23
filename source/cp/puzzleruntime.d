module cp.puzzleruntime;

import std.path: buildPath, dirName;
import std.file: exists, mkdirRecurse, rmdirRecurse;
import std.exception: enforce;
import std.algorithm: canFind;

import cp.session;
import cp.puzzles.puzzle;
import cp.languages.language;
import cp.communicationchannel;

interface IfPuzzleRuntime 
{
    void initPuzzle(string puzzleName, string language, bool forceRecreation);
    void playPuzzle(string puzzleName, string language, string compiler, bool forceRecompilation);
    void playPuzzle(string puzzleName, string[] testcases, IfCommunicationChannel commChannel);
}

class PuzzleRuntime : IfPuzzleRuntime
{
    private IfSession _session;
    
    this(IfSession session)
    {
        _session = session;
    }
    
    void initPuzzle(string puzzleName, string language, bool forceRecreation)
    {
        auto puzzle = getPuzzle(puzzleName);
        _session.logger.gameInfo("Init puzzle " ~ puzzle.metadata.name ~ " for language " ~ language);

        string puzzleLanguageFolder = buildPath(getPuzzleFolder(puzzle.metadata.name), language);

        if (exists(puzzleLanguageFolder))
        {
            if (forceRecreation)
            {
                rmdirRecurse(puzzleLanguageFolder);
            }
            else
            {
                throw new Exception ("Puzzle " ~ puzzle.metadata.name ~ " already exists for language " ~ language);
            }
        }

        mkdirRecurse(puzzleLanguageFolder);
        auto lang = getLanguage(_session, language);
        lang.createPuzzle(puzzleLanguageFolder, puzzle);
    }
    
    void playPuzzle(string puzzleName, string language, string compiler, bool forceRecompilation)
    {
        auto puzzle = getPuzzle(puzzleName);
        _session.logger.gameInfo("Play puzzle " ~ puzzle.metadata.name);

        string puzzleLanguageFolder = buildPath(getPuzzleFolder(puzzle.metadata.name), language);
        enforce(exists(puzzleLanguageFolder), 
            "Puzzle " ~ puzzle.metadata.name ~ " not exists for language " ~ language);

        auto lang = getLanguage(_session, language);
        auto commChannel = lang.startSolver(puzzleLanguageFolder, puzzle, compiler, forceRecompilation);
        foreach(testcase; puzzle.testcases)
        {
            playPuzzleTestcase(puzzle, testcase, commChannel);
        }
        _session.logger.gameInfo("All testcases succeeded");
    }
    
    void playPuzzle(string puzzleName, string[] testcases, IfCommunicationChannel commChannel)
    {
        auto puzzle = getPuzzle(puzzleName);
        _session.logger.gameInfo("Play puzzle " ~ puzzle.metadata.name);
        
        foreach(testcase; puzzle.testcases)
        {
            if (testcases.length && !testcases.canFind(testcase.name))
            {
                continue;
            }
            playPuzzleTestcase(puzzle, testcase, commChannel);
        }
        _session.logger.gameInfo("All testcases succeeded");
    }
    
    private void playPuzzleTestcase(Puzzle puzzle, TestcaseMetadata testcaseMetadata, IfCommunicationChannel commChannel)
    {
        Object testObject = puzzle.create();
        puzzle.setSession(testObject, _session);
        puzzle.setCommunicationChannel(testObject, commChannel);
 
        try
        {
            commChannel.openChannel();
            _session.logger.gameInfo("Run testcase `" ~ testcaseMetadata.description  ~ "`");
            puzzle.executeTestcase(testObject, testcaseMetadata.name);
            
            string debugOutput = commChannel.receiveDebug();
            if (debugOutput != "")
            {
                _session.logger.puzzleErr(debugOutput);
            }
            
            _session.logger.gameInfo("Testcase `" ~ testcaseMetadata.description  ~ "` succeeded.\n");
            
        }
        finally
        {
            commChannel.closeChannel();
        }

    }

    private string getPuzzleFolder(string puzzleName)
    {
        import std.process : environment;
        
        version (Windows)
        {
            return buildPath(environment.get("USERPROFILE"), "coding-puzzles", puzzleName);
        }
        else version (Posix)
        {
            return buildPath(environment.get("HOME"), "coding-puzzles", puzzleName);
        }
        else static assert("Operation system not supported");
    }
}
