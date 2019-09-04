module cp.puzzles.codingame.medium.thereisnospoonepisode1;

import std;
import cp.puzzles.puzzle;

class ThereIsNoSpoonEpisode1
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.medium.there-is-no-spoon-episode-1",
            description : "https://www.codingame.com/training/medium/there-is-no-spoon-episode-1",
            gameLoop : false
        };
        return metadata;
    }
    
    @Testcase
    void example()
    {
        outputProperty("coordinates").length = 3;
        
        play(2, 2, ["00", "0."]).validate([
            "001001",
            "10-1-1-1-1",
            "01-1-1-1-1"
        ]);
    }
    
    @Testcase
    horizontal()
    {
        outputProperty("coordinates").length = 3;
        
        play(5, 1, ["0.0.0"]).validate([
            "0020-1",
            "2040-1",
            "40-1-1-1-1"
        ]);
    }
    
    @Testcase
    vertical()
    {
        outputProperty("coordinates").length = 4;
        
        play(1, 4, ["0", "0", "0", "0"]).validate([
            "00-1-101",
            "01-1-102",
            "02-1-103",
            "03-1-1-1-1"
        ]);
    }
}

private struct Input
{
    int width;
    int height;
    @LengthRef("height")
    string[] widthCharacters;
}

private struct Output
{
    string[] coordinates;
}
