interface Util
    exposes [
        log,
        min,
        max,
        clamp,
        sign,
        intToStr,
        testAll,
    ]
    imports [
        UnitTest
    ]
    
log = \logs, items -> List.append logs (Str.joinWith items ", ")
    
min : Num a, Num a -> Num a
min = \a, b -> if a <= b then a else b

testMin = \test ->                                                        
    test                                                                  
    |> UnitTest.group "min"
    |> UnitTest.commutative min 0 0 0
    |> UnitTest.commutative min 0 1 0
    |> UnitTest.commutative min 0 -1 -1

max : Num a, Num a -> Num a
max = \a, b -> if a >= b then a else b

testMax = \test ->                                                        
    test                                                                  
    |> UnitTest.group "max"
    |> UnitTest.commutative max 0 0 0
    |> UnitTest.commutative max 0 1 1
    |> UnitTest.commutative max 0 -1 0

clamp : Num a, Num a, Num a -> Num a
clamp = \num, numMin, numMax -> min num numMax |> max numMin

testClamp = \test ->                                                        
    test                                                                  
    |> UnitTest.group "clamp"
    |> UnitTest.true ((clamp 0 0 0) == 0)
    |> UnitTest.true ((clamp 1 0 0) == 0)
    |> UnitTest.true ((clamp 1 -1 1) == 1)
    |> UnitTest.true ((clamp 1 -1 2) == 1)
    |> UnitTest.true ((clamp 5 -1 1) == 1)
    |> UnitTest.true ((clamp -5 -1 1) == -1)

sign : Num a -> Num a
sign = \num ->
    if num == 0 then 0
    else if num > 0 then 1
    else -1
    
testSign = \test ->                                                        
    test                                                                  
    |> UnitTest.group "sign"
    |> UnitTest.true ((sign 0) == 0)
    |> UnitTest.true ((sign -1) == -1)
    |> UnitTest.true ((sign 1) == 1)
    |> UnitTest.true ((sign -2) == -1)
    |> UnitTest.true ((sign 2) == 1)

# TODO Num.toStr still crashes for numbers > 9
intToStr : Int a -> Str
intToStr = \num ->
    loop = \s, n ->
        if n < 10 then
            Str.concat s (Num.toStr n)
        else
            base = n // 10
            remainder = n - (base * 10)
            loop s base |> loop remainder
    loop "" num
        
testIntToStr = \test ->                                                        
    test                                                                  
    |> UnitTest.group "intToStr"
    |> UnitTest.true ((intToStr 0) == "0")
    |> UnitTest.true ((intToStr 1) == "1")
    |> UnitTest.true ((intToStr 9) == "9")
    |> UnitTest.true ((intToStr 10) == "10")
    |> UnitTest.true ((intToStr 11) == "11")
    |> UnitTest.true ((intToStr -1) == "-1")
    |> UnitTest.true ((intToStr -9) == "-9")
    |> UnitTest.true ((intToStr -10) == "-10")
    |> UnitTest.true ((intToStr -11) == "-11")
        
testAll = \test ->
    test
    |> UnitTest.module "Util"
    |> testMin
    |> testMax
    |> testClamp
    |> testSign
    |> testIntToStr