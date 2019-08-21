module cp.puzzles.codingame.easy.onboarding;

import cp.puzzles.puzzle;

class Onboarding
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.easy.Onboarding",
            description : "https://www.codingame.com/ide/puzzle/onboarding",
            gameLoop : true
        };
        return metadata;
    }
    
    @Testcase
    void imminentDanger()
    {
        Output o = play(Input("e1", 3, "e2", 4));
        //validate(Output("e1"), o);
    }
}

private struct Input
{
    string enemy1;
    int dist1;
    string enemy2;
    int dist2;
}

private struct Output
{
    string enemy;
}
