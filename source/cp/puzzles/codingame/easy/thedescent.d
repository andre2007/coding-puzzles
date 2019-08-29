module cp.puzzles.codingame.easy.thedescent;

import std;
import cp.puzzles.puzzle;

class TheDescent
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.easy.the-descent",
            description : "https://www.codingame.com/training/easy/the-descent",
            gameLoop : true
        };
        return metadata;
    }
    
    @Testcase
    void descendingMountains()
    {
        int[8] mountainHeights = iota(1,9).randomCover.array;
        
        foreach_reverse(n; 1..9)
        {
            auto idx = mountainHeights[].countUntil(n);
            play(mountainHeights).validate(idx);
            mountainHeights[idx] = 0;
        }
    }
}

private struct Input
{
    int[8] mountainHeights;
}

private struct Output
{
    ptrdiff_t mountainIndex;
}
