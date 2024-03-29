module cp.puzzles.codingame.medium.letsgotothecinema;

import std;
import cp.puzzles.puzzle;

class LetsGoToTheCinema
{
    mixin PuzzleBase!(Input, Output);
    
    static PuzzleMetadata metadata()
    {
        PuzzleMetadata metadata = {
            name : "cg.medium.lets-go-to-the-cinema",
            description : "https://www.codingame.com/training/medium/lets-go-to-the-cinema",
            gameLoop : false
        };
        return metadata;
    }
    
    @Testcase
    void example()
    {        
        play(2, 4, 4, [
            Group(2, 1, 2),
            Group(2, 1, 1),
            Group(2, 0, 1),
            Group(2, 1, 1),
        ]).validate(2, 5);
    }
    
    @Testcase("Family comes to living room to watch TV")
    void testcase1()
    {        
        play(1, 4, 1, [
            Group(4, 0, 0),
        ]).validate(1, 4);
    }
    
    @Testcase("Family TV, but cat is sitting on edge of sofa")
    void testcase2()
    {        
        play(1, 5, 2, [
            Group(1, 0, 0),
            Group(4, 0, 0),
        ]).validate(1, 4);
    }
    
    @Testcase("Family TV, but 2 cats are sitting on middle of sofa")
    void testcase3()
    {        
        play(1, 6, 3, [
            Group(1, 0, 2),
            Group(1, 0, 4),
            Group(4, 0, 1),
        ]).validate(2, 4);
    }
    
    @Testcase("There Ain't No Problem!")
    void testcase4()
    {        
        play(3, 6, 7, [
            Group(2, 2, 4),
            Group(1, 0, 5),
            Group(2, 2, 2),
            Group(2, 2, 0),
            Group(6, 1, 0),
            Group(3, 0, 0),
            Group(2, 0, 3),
        ]).validate(7, 18);
    }
    
    @Testcase("There Ain't No Problem!")
    void testcase5()
    {        
        play(3, 6, 7, [
            Group(1, 0, 0),
            Group(2, 0, 0),
            Group(2, 0, 0),
            Group(2, 0, 0),
            Group(6, 0, 0),
            Group(3, 0, 0),
            Group(2, 0, 0),
        ]).validate(1, 2);
    }
    
    

/*
# Small cinema

## Input
19 10
33
7 6 1
9 12 1
2 12 3
9 11 1
9 4 0
5 0 0
5 6 5
8 4 1
9 8 1
8 14 0
3 10 4
7 11 2
2 15 4
3 12 2
1 10 3
2 13 6
4 12 4
9 1 0
8 10 0
9 16 1
3 5 7
4 14 4
10 15 0
4 12 1
1 6 3
7 14 2
7 3 1
2 18 6
10 0 0
8 15 1
5 10 4
8 12 1
2 3 3

## Output
9 75

# Bigger cinema
 
## Input
91 67
185
66 11 0
43 80 4
33 85 8
7 60 50
30 74 1
6 23 43
26 87 32
57 9 0
1 47 1
29 25 13
31 86 11
11 61 31
51 33 9
28 23 25
56 9 4
37 49 24
30 33 6
47 18 6
31 32 15
9 22 55
67 73 0
51 73 1
7 37 5
63 34 0
40 53 13
57 70 8
22 12 4
22 54 35
26 40 10
34 76 32
1 46 11
48 78 12
63 18 3
1 6 39
55 60 12
50 86 16
31 33 21
43 2 4
22 64 40
2 6 31
41 47 24
33 26 30
29 55 23
44 69 7
48 88 19
63 11 4
49 75 1
23 31 29
57 26 5
31 33 21
3 45 61
47 54 17
28 56 26
27 4 1
34 9 6
7 29 29
45 68 11
18 63 48
37 80 4
52 22 4
58 83 7
40 54 2
27 65 2
14 19 2
52 16 4
5 39 41
45 80 10
64 90 3
58 30 5
19 53 25
56 14 3
24 81 6
63 9 4
32 71 19
2 35 35
21 46 19
41 20 2
8 43 38
27 50 20
35 3 20
48 71 2
22 31 27
53 85 6
34 52 8
1 65 46
55 20 3
37 38 17
24 9 30
65 27 1
9 18 5
29 13 22
49 20 2
43 54 2
27 65 16
12 52 16
52 3 8
52 61 0
16 12 40
36 44 13
4 56 49
22 9 18
35 18 24
53 38 3
42 62 24
21 22 17
21 19 34
53 47 0
7 84 52
16 2 47
9 81 7
52 6 15
59 79 6
51 73 3
18 6 28
63 8 1
19 38 14
33 61 16
49 76 0
17 53 41
27 55 15
55 8 4
48 44 1
35 78 21
1 88 14
47 52 15
28 78 28
35 61 3
46 40 1
61 10 5
4 2 32
54 57 2
21 30 43
40 72 26
14 0 0
10 14 3
40 39 15
1 24 61
64 81 1
11 50 52
53 79 4
42 29 24
59 22 6
32 7 8
62 82 1
63 78 4
11 6 21
3 27 52
33 63 25
53 81 8
6 85 2
36 72 13
36 52 2
49 61 10
13 71 26
50 66 17
8 57 56
20 38 26
7 20 16
17 70 48
8 51 47
59 72 7
31 58 11
12 69 21
10 53 49
28 13 18
62 16 0
35 1 8
4 90 60
34 80 3
13 28 12
50 31 2
15 12 14
31 11 16
26 35 32
7 75 26
17 59 8
48 26 15
23 83 34
38 26 24
58 41 5
45 6 3
67 1 0
20 63 46
11 38 32
1 19 21

## Output
66 2043
*/


    @Testcase("Chain Reaction")
    void testcase8()
    {        
        play(2, 4, 8, [
            Group(1, 0, 0),
            Group(1, 0, 0),
            Group(1, 0, 1),
            Group(1, 0, 2),
            Group(1, 0, 3),
            Group(1, 1, 3),
            Group(1, 1, 2),
            Group(1, 1, 1)
        ]).validate(1, 1);
    }
    
    @Testcase("Blind Date")
    void testcase9()
    {        
        play(1, 16, 9, [
            Group(1, 0, 1),
            Group(1, 0, 3),
            Group(1, 0, 5),
            Group(1, 0, 7),
            Group(1, 0, 9),
            Group(1, 0, 11),
            Group(1, 0, 13),
            Group(1, 0, 15),
            Group(8, 0, 0)
        ]).validate(8, 12);
    }
}

struct Group
{
    @Join int numPersons;
    @Join int row;
    int column;
}

private struct Input
{
    @Join int maxRow;
    int maxColumn;
    
    int numGroups;
    @LengthRef("numGroups")
    Group[] groups;
}

private struct Output
{
    @Join int groupSuccess;
    int personSuccess;
}

unittest
{   
    import cp.tests.common;
    
    executeTestcase(LetsGoToTheCinema.metadata.name, "example", (i, o, e) {
        auto inputs = i.readln().strip().split(" ");
        assert(inputs == ["2", "4"]);
        
        int numGroups = i.readln().strip().to!int;
        assert(numGroups == 4);
        Group[] groups;
        
        foreach(n; 0..4)
        {
            inputs = i.readln().strip().split(" ");
            groups ~= Group(inputs[0].to!int, inputs[1].to!int, inputs[2].to!int);
        }
        
        assert (groups == [Group(2, 1, 2), Group(2, 1, 1), Group(2, 0, 1), Group(2, 1, 1)]);
        o.writeln("2 5");
    }); 
}
