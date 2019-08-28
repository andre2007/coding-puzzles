module cp.puzzleruntime;

import std.path: buildPath, dirName;
import std.file: exists, mkdirRecurse, rmdirRecurse;
import std.exception: enforce;

import cp.session;
import cp.puzzles.puzzle;
import cp.languages.language;

interface IfPuzzleRuntime 
{
    void initPuzzle(string puzzleName, string language, bool forceRecreation);
    void playPuzzle(string puzzleName, string language, string compiler, bool forceRecompilation);
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
        string puzzleLanguageFolder = buildPath(getPuzzleFolder(puzzleName), language);
        
        if (exists(puzzleLanguageFolder))
        {
            if (forceRecreation)
            {
                rmdirRecurse(puzzleLanguageFolder);
            }
            else
            {
                throw new Exception ("Puzzle " ~ puzzleName ~ " already exists for language " ~ language);
            }
        }

        mkdirRecurse(puzzleLanguageFolder);
        auto puzzle = getPuzzle(puzzleName);
        auto lang = getLanguage(_session, language);
        lang.createPuzzle(puzzleLanguageFolder, puzzle);
    }
    
    void playPuzzle(string puzzleName, string language, string compiler, bool forceRecompilation)
    {
        _session.logger.gameInfo("Play puzzle " ~ puzzleName);
        
        string puzzleLanguageFolder = buildPath(getPuzzleFolder(puzzleName), language);
        enforce(exists(puzzleLanguageFolder), 
            "Puzzle " ~ puzzleName ~ " not exists for language " ~ language);

        auto puzzle = getPuzzle(puzzleName);
        auto lang = getLanguage(_session, language);
        auto commChannel = lang.startSolver(puzzleLanguageFolder, puzzle, compiler, forceRecompilation);

        Object testObject = puzzle.create();
        puzzle.setSession(testObject, _session);
        puzzle.setCommunicationChannel(testObject, commChannel);

        try
        {
            commChannel.openChannel();
            
            foreach(name; puzzle.testcases)
            {
                _session.logger.gameInfo("Run testcase " ~ name);
                puzzle.testcase(testObject, name);
            }
            
            _session.logger.gameInfo("Success");
        }
        finally
        {
            commChannel.closeChannel();
        }
    }

    private string getPuzzleFolder(string puzzleName)
    {
        import std.file : thisExePath;
        
        return buildPath(dirName(thisExePath), "puzzles", puzzleName);
    }
        
}
