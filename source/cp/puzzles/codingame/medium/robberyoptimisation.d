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
    
    @Testcase
    void threeHousesOne()
    {
        play(3, [1, 2, 3]).validate(4);
    }
    
    @Testcase
    void threeHousesTwo()
    {
        play(3, [1, 5, 2]).validate(5);
    }
    
    @Testcase
    void nineIdenticalHouses()
    {
        play(9, [10, 10, 10, 10, 10, 10, 10, 10, 10]).validate(50);
    }
    
    @Testcase
    void oneHouse()
    {
        play(1, [5]).validate(5);
    }
    
    @Testcase
    void dontJustAlternateHouses()
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

unittest
{   
    import cp.tests.common;
    
    executeTestcase(RobberyOptimisation.metadata.name, "example", (i, o, e) {
        int houses = i.readln().strip().to!int;
        assert (houses == 5);
        
        int[] houseValues = houses.iota.map!(n => i.readln().strip().to!int).array;
        assert (houseValues == [1, 15, 10, 13, 16]);
        o.writeln("31");
    }); 
}
