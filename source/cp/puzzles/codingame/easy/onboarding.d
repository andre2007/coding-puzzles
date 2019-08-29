module cp.puzzles.codingame.easy.onboarding;

import std;
import cp.puzzles.puzzle;

class Onboarding
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.easy.onboarding",
            description : "https://www.codingame.com/ide/puzzle/onboarding",
            gameLoop : true
        };
        return metadata;
    }
    
    @Testcase
    void imminentDanger()
    {
        foreach(n; 0..10)
        {
            int i1 = uniform(0, 100);
            int i2 = uniform(0, 100);
            
            while (i2 == i1)
            {
                i2 = uniform(0, 100);
            }
            
            play("e1", i1, "e2", i2).validate(i1 < i2 ? "e1" : "e2");
        }
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
