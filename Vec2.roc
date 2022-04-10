interface Vec2
    exposes [
        Vec2,
        vec2,
        zero, one,
        add, subtract, multiply, divide,
        min, max, midpoint,
        boundsMin, boundsMax, boundsCenter,
        toStr,
        testAll,
    ]
    imports [
        UnitTest,
        Util,
    ]

Vec2 : {
    x : I32,
    y : I32
}

vec2 : Int a, Int b -> Vec2
vec2 = \x, y ->
    { x : Num.toI32 x, y : Num.toI32 y }
    
zero : Vec2
zero = vec2 0 0

one : Vec2
one = vec2 1 1

Vec2n a: {x : Num a, y : Num a}  
Vec2i a: {x : Int a, y : Int a}  
    
add : Vec2n a, Vec2n a -> Vec2n a
add = \a, b ->
    { x : a.x + b.x, y : a.y + b.y }
    
testAdd = \test ->                                                        
    test                                                                  
    |> UnitTest.group "add"
    |> UnitTest.true ((add (vec2 0 0) (vec2 0 0)) == (vec2 0 0))                                           
    |> UnitTest.true ((add (vec2 0 0) (vec2 1 1)) == (vec2 1 1))    
    |> UnitTest.true ((add (vec2 1 1) (vec2 1 1)) == (vec2 2 2))    
    |> UnitTest.true ((add (vec2 1 0) (vec2 0 1)) == (vec2 1 1))    
    |> UnitTest.true ((add (vec2 0 1) (vec2 1 0)) == (vec2 1 1))   
    |> UnitTest.true ((add (vec2 -2 3) (vec2 -2 3)) == (vec2 -4 6))
    |> UnitTest.true ((add (vec2 -2 3) (vec2 2 -3)) == (vec2 0 0))
    
subtract : Vec2n a, Vec2n a -> Vec2n a
subtract = \a, b ->
    { x : a.x - b.x, y : a.y - b.y }
    
testSubtract = \test ->                                                
    test                                                                  
    |> UnitTest.group "subtract"
    |> UnitTest.true ((subtract (vec2 0 0) (vec2 0 0)) == (vec2 0 0))                                           
    |> UnitTest.true ((subtract (vec2 0 0) (vec2 1 1)) == (vec2 -1 -1))    
    |> UnitTest.true ((subtract (vec2 1 1) (vec2 1 1)) == (vec2 0 0))    
    |> UnitTest.true ((subtract (vec2 1 0) (vec2 0 1)) == (vec2 1 -1))    
    |> UnitTest.true ((subtract (vec2 0 1) (vec2 1 0)) == (vec2 -1 1))   
    |> UnitTest.true ((subtract (vec2 -2 3) (vec2 -2 3)) == (vec2 0 0))
    |> UnitTest.true ((subtract (vec2 -2 3) (vec2 2 -3)) == (vec2 -4 6))
    
multiply : Vec2n a, Vec2n a -> Vec2n a
multiply = \a, b ->
    { x : a.x * b.x, y : a.y * b.y }
    
testMultiply = \test ->                                                        
    test                                                                  
    |> UnitTest.group "multiply"
    |> UnitTest.true ((multiply (vec2 0 0) (vec2 0 0)) == (vec2 0 0))                                           
    |> UnitTest.true ((multiply (vec2 0 0) (vec2 1 1)) == (vec2 0 0))    
    |> UnitTest.true ((multiply (vec2 1 1) (vec2 1 1)) == (vec2 1 1))    
    |> UnitTest.true ((multiply (vec2 1 0) (vec2 0 1)) == (vec2 0 0))    
    |> UnitTest.true ((multiply (vec2 0 1) (vec2 1 0)) == (vec2 0 0))   
    |> UnitTest.true ((multiply (vec2 -2 3) (vec2 -2 3)) == (vec2 4 9))
    |> UnitTest.true ((multiply (vec2 -2 3) (vec2 2 -3)) == (vec2 -4 -9))
    
divide : Vec2i a, Vec2i a -> Vec2i a
divide = \a, b ->
    { x : a.x // b.x |> Result.withDefault 0, y : a.y // b.y |> Result.withDefault 0 }
    
testDivide = \test ->                                                        
    test                                                                  
    |> UnitTest.group "divide"
    |> UnitTest.true ((divide (vec2 0 0) (vec2 0 0)) == (vec2 0 0))                                           
    |> UnitTest.true ((divide (vec2 0 0) (vec2 1 1)) == (vec2 0 0))    
    |> UnitTest.true ((divide (vec2 1 1) (vec2 1 1)) == (vec2 1 1))    
    |> UnitTest.true ((divide (vec2 1 0) (vec2 0 1)) == (vec2 0 0))    
    |> UnitTest.true ((divide (vec2 0 1) (vec2 1 0)) == (vec2 0 0))   
    |> UnitTest.true ((divide (vec2 2 4) (vec2 2 2)) == (vec2 1 2))
    |> UnitTest.true ((divide (vec2 -2 -4) (vec2 2 2)) == (vec2 -1 -2))   
    |> UnitTest.true ((divide (vec2 -2 -4) (vec2 -2 -2)) == (vec2 1 2))   
    
min: Vec2n a, Vec2n a -> Vec2n a
min = \a, b ->
    x = Util.min a.x b.x
    y = Util.min a.y b.y
    {x, y}
    
testMin = \test ->
    test
    |> UnitTest.group "min"
    |> UnitTest.true ((min (vec2 0 0) (vec2 0 0)) == (vec2 0 0))
    |> UnitTest.true ((min (vec2 0 0) (vec2 1 1)) == (vec2 0 0))
    |> UnitTest.true ((min (vec2 1 1) (vec2 0 0)) == (vec2 0 0))
    |> UnitTest.true ((min (vec2 1 0) (vec2 0 1)) == (vec2 0 0))
    |> UnitTest.true ((min (vec2 0 1) (vec2 1 0)) == (vec2 0 0))
 
max: Vec2n a, Vec2n a -> Vec2n a
max = \a, b ->
    x = Util.max a.x b.x
    y = Util.max a.y b.y
    {x, y}
    
testMax = \test ->
    test
    |> UnitTest.group "max"
    |> UnitTest.true ((max (vec2 0 0) (vec2 0 0)) == (vec2 0 0))
    |> UnitTest.true ((max (vec2 0 0) (vec2 1 1)) == (vec2 1 1))
    |> UnitTest.true ((max (vec2 1 1) (vec2 0 0)) == (vec2 1 1))
    |> UnitTest.true ((max (vec2 1 0) (vec2 0 1)) == (vec2 1 1))
    |> UnitTest.true ((max (vec2 0 1) (vec2 1 0)) == (vec2 1 1))
    
# TODO crashes compiler
#midpoint : Vec2i a, Vec2i a -> Vec2i a
midpoint : Vec2, Vec2 -> Vec2
midpoint = \a, b -> subtract b a |> divide (vec2 2 2) |> add a

testMidpoint = \test ->
    test
    |> UnitTest.group "midpoint"
    |> UnitTest.true ((midpoint (vec2 0 0) (vec2 0 0)) == (vec2 0 0))
    |> UnitTest.true ((midpoint (vec2 0 0) (vec2 1 1)) == (vec2 0 0))
    |> UnitTest.true ((midpoint (vec2 0 0) (vec2 2 2)) == (vec2 1 1))
    |> UnitTest.true ((midpoint (vec2 0 0) (vec2 -2 -2)) == (vec2 -1 -1))
    |> UnitTest.true ((midpoint (vec2 0 0) (vec2 3 3)) == (vec2 1 1))
    |> UnitTest.true ((midpoint (vec2 0 0) (vec2 -3 -3)) == (vec2 -1 -1))

# TODO wanted to return Result but compiler was crashing
boundsMin : List Vec2 -> Vec2
boundsMin = \list ->
    m = List.first list |> Result.withDefault (vec2 0 0)
    List.walk list m min
    
testBoundsMin = \test ->
    test
    |> UnitTest.group "boundsMin"
    |> UnitTest.true ((boundsMin [(vec2 0 0), (vec2 0 0)]) == (vec2 0 0))
    |> UnitTest.true ((boundsMin [(vec2 0 0), (vec2 1 1)]) == (vec2 0 0))
    |> UnitTest.true ((boundsMin [(vec2 -1 -1), (vec2 0 0)]) == (vec2 -1 -1))
    |> UnitTest.true ((boundsMin [(vec2 1 1), (vec2 -1 2)]) == (vec2 -1 1))
    |> UnitTest.true ((boundsMin [(vec2 1 -1), (vec2 0 1)]) == (vec2 0 -1))
    
# TODO wanted to return Result but compiler was crashing
boundsMax : List Vec2 -> Vec2
boundsMax = \list ->
    m = List.first list |> Result.withDefault (vec2 0 0)
    List.walk list m max
    
testBoundsMax = \test ->
    test
    |> UnitTest.group "boundsMax"
    |> UnitTest.true ((boundsMax [(vec2 0 0), (vec2 0 0)]) == (vec2 0 0))
    |> UnitTest.true ((boundsMax [(vec2 0 0), (vec2 1 1)]) == (vec2 1 1))
    |> UnitTest.true ((boundsMax [(vec2 -1 -1), (vec2 0 0)]) == (vec2 0 0))
    |> UnitTest.true ((boundsMax [(vec2 1 1), (vec2 -1 2)]) == (vec2 1 2))
    |> UnitTest.true ((boundsMax [(vec2 1 -1), (vec2 0 1)]) == (vec2 1 1))
        
# TODO wanted to return Result but compiler was crashing
boundsCenter : List Vec2 -> Vec2
boundsCenter = \list -> midpoint (boundsMin list) (boundsMax list)

testBoundsCenter = \test ->
    test
    |> UnitTest.group "boundsCenter"
    |> UnitTest.true ((boundsCenter [(vec2 0 0), (vec2 0 0)]) == (vec2 0 0))
    |> UnitTest.true ((boundsCenter [(vec2 0 0), (vec2 1 1)]) == (vec2 0 0))
    |> UnitTest.true ((boundsCenter [(vec2 0 0), (vec2 2 2)]) == (vec2 1 1))
    |> UnitTest.true ((boundsCenter [(vec2 -1 -1), (vec2 1 1)]) == (vec2 0 0))
    |> UnitTest.true ((boundsCenter [(vec2 0 0), (vec2 4 0)]) == (vec2 2 0))
    |> UnitTest.true ((boundsCenter [(vec2 0 0), (vec2 0 4)]) == (vec2 0 2))
    
toStr : Vec2 -> Str
toStr = \v ->
    x = Num.toStr v.x
    y = Num.toStr v.y
    "{x:\(x), y:\(y)}"
    
testAll = \test ->
    test
    |> UnitTest.module "Vec2"
    |> testAdd
    |> testSubtract
    |> testMultiply
    |> testDivide
    |> testMin
    |> testMax
    |> testMidpoint
    |> testBoundsMin
    |> testBoundsMax
    |> testBoundsCenter