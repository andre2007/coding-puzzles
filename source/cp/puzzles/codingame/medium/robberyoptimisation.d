module cp.puzzles.codingame.medium.robberyoptimisation;

import std;
import cp.puzzles.puzzle;

class RobberyOptimisation
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.medium.robbery-optimisation",
            description : "https://www.codingame.com/training/medium/robbery-optimisation",
            gameLoop : false
        };
        return metadata;
    }
    
    @Testcase
    void example()
    {        
        play(5, [1, 15, 10, 13, 16]).validate(31);
    }
}

private struct Input
{
    int houses;
    @LengthRef("houses")
    int[] houseValues;
}

private struct Output
{
    int maxAmount;
}
