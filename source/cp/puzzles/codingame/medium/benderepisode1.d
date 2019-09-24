module cp.puzzles.codingame.medium.benderepisode1;

import std;
import cp.puzzles.puzzle;

class BenderEpisode1
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.medium.bender-episode-1",
            description : "https://www.codingame.com/training/medium/bender-episode-1",
            gameLoop : false
        };
        return metadata;
    }
    
    @Testcase("Simple moves")
    void testcase1()
    {
        outputProperty("moves").length = 4;
        play(5, 5, [
            "#####", 
            "#@  #", 
            "#   #", 
            "#  $#", 
            "#####"
        ]).validate([
            "SOUTH", "SOUTH", 
            "EAST", "EAST"]);
    }
    
    @Testcase("Obstacles")
    void testcase2()
    {
        outputProperty("moves").length = 9;
        play(8, 8, [
            "########", 
            "# @    #", 
            "#     X#", 
            "# XXX  #", 
            "#   XX #", 
            "#   XX #", 
            "#     $#", 
            "########"
        ]).validate([
            "SOUTH", 
            "EAST", "EAST", "EAST", 
            "SOUTH", 
            "EAST", 
            "SOUTH", "SOUTH", "SOUTH"]);
    }
    
    @Testcase("Priorities")
    void testcase3()
    {
        outputProperty("moves").length = 10;
        play(8, 8, [
            "########", 
            "#     $#",
            "#      #", 
            "#      #", 
            "#  @   #", 
            "#      #", 
            "#      #", 
            "########"
        ]).validate([
            "SOUTH", "SOUTH", 
            "EAST", "EAST", "EAST", 
            "NORTH", "NORTH", "NORTH", "NORTH", "NORTH"]);
    }
    
    @Testcase("Straight line")
    void testcase4()
    {
        outputProperty("moves").length = 8;
        play(8, 8, [
            "########", 
            "#      #",
            "# @    #",
            "# XX   #",
            "#  XX  #",
            "#   XX #",
            "#     $#",
            "########"
        ]).validate([
            "EAST", "EAST", "EAST", "EAST", 
            "SOUTH", "SOUTH", "SOUTH", "SOUTH"]);
    }
    
    @Testcase("Path modifier")
    void testcase5()
    {
        outputProperty("moves").length = 20;
        play(10, 10, [
            "##########", 
            "#        #",
            "#  S   W #",
            "#        #",
            "#  $     #",
            "#        #",
            "#@       #",
            "#        #",
            "#E     N #",
            "##########"
        ]).validate([
            "SOUTH", "SOUTH", 
            "EAST", "EAST", "EAST", "EAST", "EAST", "EAST",
            "NORTH","NORTH","NORTH","NORTH","NORTH","NORTH",
            "WEST", "WEST","WEST", "WEST", 
            "SOUTH", "SOUTH"]);
    }
    
    @Testcase("Breaker mode")
    void testcase6()
    {
        outputProperty("moves").length = 10;
        play(10, 10, [
            "##########", 
            "# @      #",
            "# B      #",
            "#XXX     #",
            "# B      #",
            "#    BXX$#",
            "#XXXXXXXX#",
            "#        #",
            "#        #",
            "##########"
        ]).validate([
            "SOUTH", "SOUTH", "SOUTH", "SOUTH", 
            "EAST", "EAST", "EAST", "EAST", "EAST", "EAST",
        ]);
    }
    
    @Testcase("Inverter")
    void testcase7()
    {
        outputProperty("moves").length = 27;
        play(10, 10, [
            "##########", 
            "#    I   #",
            "#        #",
            "#       $#",
            "#       @#",
            "#        #",
            "#       I#",
            "#        #",
            "#        #",
            "##########"
        ]).validate([
            "SOUTH", "SOUTH", "SOUTH", "SOUTH", 
            "WEST", "WEST", "WEST", "WEST", "WEST", "WEST", "WEST",
            "NORTH", "NORTH", "NORTH", "NORTH", "NORTH", "NORTH", "NORTH", 
            "EAST", "EAST", "EAST", "EAST", "EAST", "EAST", "EAST", 
            "SOUTH", "SOUTH"
        ]);
    }
    
    @Testcase("Teleport")
    void testcase8()
    {
        outputProperty("moves").length = 17;
        play(10, 10, [
            "##########", 
            "#    T   #",
            "#        #",
            "#        #",
            "#        #",
            "#@       #",
            "#        #",
            "#        #",
            "#    T  $#",
            "##########"
        ]).validate([
            "SOUTH", "SOUTH", "SOUTH",
            "EAST", "EAST", "EAST", "EAST", "EAST", "EAST", "EAST", 
            "SOUTH", "SOUTH", "SOUTH", "SOUTH", "SOUTH", "SOUTH", "SOUTH"
        ]);
    }
    
    @Testcase("Broken wall?")
    void testcase9()
    {
        outputProperty("moves").length = 23;
        play(10, 10, [
            "##########", 
            "#        #",
            "#  @     #",
            "#  B     #",
            "#  S   W #",
            "# XXX    #",
            "#  B   N #",
            "# XXXXXXX#",
            "#       $#",
            "##########"
        ]).validate([
            "SOUTH", "SOUTH", "SOUTH", "SOUTH",
            "EAST", "EAST", "EAST", "EAST",
            "NORTH", "NORTH",
            "WEST", "WEST", "WEST", "WEST", 
            "SOUTH", "SOUTH", "SOUTH", "SOUTH",
            "EAST", "EAST", "EAST", "EAST", "EAST",
        ]);
    }
    
    @Testcase("All together")
    void testcase10()
    {
        outputProperty("moves").length = 55;
        play(15, 15, [
            "###############", 
            "#      IXXXXX #",
            "#  @          #",
            "#             #",
            "#             #",
            "#  I          #",
            "#  B          #",
            "#  B   S     W#",
            "#  B   T      #",
            "#             #",
            "#         T   #",
            "#         B   #",
            "#            $#",
            "#        XXXX #",
            "###############"
        ]).validate([
            "SOUTH", "SOUTH", "SOUTH", "SOUTH","SOUTH","SOUTH","SOUTH","SOUTH","SOUTH","SOUTH","SOUTH",
            "WEST", "WEST",
            "NORTH", "NORTH","NORTH","NORTH","NORTH","NORTH","NORTH","NORTH","NORTH","NORTH","NORTH","NORTH",
            "EAST", "EAST", "EAST", "EAST","EAST","EAST","EAST","EAST","EAST","EAST","EAST","EAST",
            "SOUTH", "SOUTH", "SOUTH", "SOUTH","SOUTH","SOUTH",
            "WEST", "WEST", "WEST", "WEST", "WEST", "WEST", 
            "SOUTH", "SOUTH", "SOUTH",
            "EAST", "EAST", "EAST"
        ]);
    }
    
    @Testcase("LOOP")
    void testcase11()
    {
        outputProperty("moves").length = 1;
        play(15, 15, [
            "###############", 
            "#      IXXXXX #",
            "#  @          #",
            "#E S          #",
            "#             #",
            "#  I          #",
            "#  B          #",
            "#  B   S     W#",
            "#  B   T      #",
            "#             #",
            "#         T   #",
            "#         B   #",
            "#N          W$#",
            "#        XXXX #",
            "###############"
        ]).validate(["LOOP"]);
    }
    
    /*@Testcase("Multiple loops?")
    void testcase12()
    {
        TODO:
    }
    */
}

private struct Input
{
    @Join
    int l;
    int c;
    @LengthRef("l")
    string[] rows;
}

private struct Output
{
    string[] moves;
}

unittest
{   
    import cp.tests.common;
    
    executeTestcase(BenderEpisode1.metadata.name, "testcase1", (i, o, e) {
        auto inputs = i.readln().strip().split(" ");
        assert(inputs == ["5", "5"]);
        
        string[] rows;
        foreach(n; 0..5)
        {
            rows ~= i.readln().strip();
        }
        
        assert(rows == ["#####", "#@  #", "#   #", "#  $#", "#####"]);
        
        o.writeln("SOUTH");
        o.writeln("SOUTH");
        o.writeln("EAST");
        o.writeln("EAST");
        //o.flush();
    }); 
}