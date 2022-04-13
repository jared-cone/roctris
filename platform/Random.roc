interface Random
    exposes [ randomU32, nextU32, rangeU32 ]
    imports [ pf.Effect, Task ]

randomU32 : Task.Task U32 *
randomU32 = Effect.after Effect.randomU32 Task.succeed

nextU32 : U32 -> U32
nextU32 = \seed ->
    # https://www.tjhsst.edu/~dhyatt/arch/random.html
    shift1 = Num.shiftRightBy 20 seed
    xor1 = Num.bitwiseXor seed shift1
    shift2 = Num.shiftLeftBy 12 xor1
    xor2 = Num.bitwiseXor seed shift2
    xor2
    
rangeU32 : U32, U32, U32 -> {randSeed : U32, randNum : U32} 
rangeU32 = \seed, incMin, incMax ->
    randSeed = nextU32 seed
    range = if incMax >= incMin then incMax - incMin + 1 else 0
    # TODO compiler crash - no support for mod U32?
    #randNum = Num.modInt randSeed range |> Result.withDefault 0 |> Num.add incMin
    div = Num.divFloorChecked randSeed range |> Result.withDefault 0
    t = div * range
    randNum = randSeed - t
    {randSeed, randNum}
    
    