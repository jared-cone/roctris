app "Test"
    packages { pf: "platform" }
    imports [
        UnitTest,
        Util,
        Vec2,
    ]
    provides [ main ] to pf

main =
    UnitTest.empty
    |> Vec2.testAll
    |> Util.testAll
    |> UnitTest.print