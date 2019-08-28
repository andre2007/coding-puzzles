module cp.languages.language;

import cp.session;
import cp.puzzles.puzzle;
import cp.communicationchannel;

interface IfLanguage
{
    void createPuzzle(string folder, Puzzle puzzle);
    
    IfCommunicationChannel startSolver(string folder, 
        Puzzle puzzle, string compiler, bool forceRecompilation);
}

IfLanguage getLanguage(IfSession session, string language)
{
    import cp.languages.d;
    
    switch(language)
    {
        case "d":
            return new LanguageD(session);
        default:
            throw new Exception("Unknown language " ~language);
    }
}
