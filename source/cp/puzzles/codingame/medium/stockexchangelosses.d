module cp.puzzles.codingame.medium.stockexchangelosses;

import std;
import cp.puzzles.puzzle;

class StockExchangeLosses
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.medium.stock-exchange-losses",
            description : "https://www.codingame.com/training/medium/stock-exchange-losses",
            gameLoop : false
        };
        return metadata;
    }
    
    @Testcase("(3 2 4 2 1 5) -> -3")
    void testcase1()
    {        
        play(6, [3, 2, 4, 2, 1, 5]).validate(-3);
    }
    
    @Testcase("Maximum Loss between the first and last values (5 3 4 2 3 1) -> -4")
    void testcase2()
    {
        play(6, [5, 3, 4, 2, 3, 1]).validate(-4);
    }
    
    @Testcase("Profit (1 2 4 4 5) -> 0")
    void testcase3()
    {
        play(5, [1, 2, 4, 4, 5]).validate(0);
    }
    
    @Testcase("Profit 2 (3 4 7 9 10) -> 0")
    void testcase4()
    {
        play(5, [3, 4, 7, 9, 10]).validate(0);
    }

    @Testcase("Varied (3 2 10 7 15 14)")
    void testcase6()
    {
        play(6, [3, 2, 10, 7, 15, 14]).validate(-3);
    }
}

private struct Input
{
    int num;
    @LengthRef("num")
    int[] values;
}

private struct Output
{
    int answer;
}
