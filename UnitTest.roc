interface UnitTest
    exposes [
        Session,
        empty,
        module,
        group,
        true,
        commutative,
        print,
    ]
    imports [
        pf.Stdout,
        pf.Task,
        pf.Terminal,
        Color,
    ]
    
TestId : {
    module : Str,
    group : Str,
    num : I32,
}

TestResult : [Pass TestId, Fail TestId]

Session : {
    current : TestId,
    results : List TestResult
}

emptyTestId : TestId
emptyTestId = { module : "", group : "", num : 0 }

empty : Session
empty = { current : emptyTestId, results : [] }

module : Session, Str -> Session
module = \test, moduleName ->
    c = test.current
    current = { c & module : moduleName }
    { test & current }

group : Session, Str -> Session
group = \test, groupName ->
    num = 0
    c = test.current
    current = { c & group : groupName, num }
    { test & current }

true : Session, Bool -> Session
true = \test, pass ->
    num = test.current.num + 1
    c = test.current
    current = { c & num }
    result = if pass then (Pass current) else (Fail current)
    results = List.append test.results result
    { test & current, results }
    
commutative : Session, (a, a -> b), a, a, b -> Session
commutative = \test, func, param1, param2, expected ->
    result1 = (func param1 param2) == expected
    result2 = (func param2 param1) == expected
    true test (result1 && result2)
   
printResult : Task.Task {} [], TestResult -> Task.Task {} []
printResult = \task, result ->
    _ <- task |> Task.await
    { test, color, resultStr } =
        when result is
            Pass testId -> { test : testId, color : Color.green, resultStr : "PASS" }
            Fail testId -> { test : testId, color : Color.red, resultStr : "FAIL" }
    numStr = Num.toStr test.num
    _ <- Terminal.forecolor color.r color.g color.b |> Task.await
    _ <- Stdout.line "\(resultStr) \(test.module).\(test.group) #\(numStr)" |> Task.await
    # TODO segfault if we just return the above task instead of waiting on it
    Task.succeed {}
    
resultIsPass = \result ->
    when result is
        Pass _ -> True
        Fail _ -> False
    
resultIsFail = \result -> !(resultIsPass result)
   
print : Session -> Task.Task {} []
print = \test ->
    _ <- Stdout.line "Unit tests START." |> Task.await
    _ <- Stdout.line "------------------------" |> Task.await
    _ <- List.walk test.results (Task.succeed {}) printResult |> Task.await
    
    _ <- Terminal.forecolorReset |> Task.await
    _ <- Stdout.line "------------------------" |> Task.await
    
    passedTests = List.keepIf test.results resultIsPass
    failedTests = List.keepIf test.results resultIsFail
    
    passed = List.len failedTests == 0
    
    # TODO crashes if type isn't explicitly given
    color : Color.Rgb8
    color = if passed then Color.green else Color.red
    
    resultStr = if passed then "PASS" else "FAIL"
    
    # TODO Num.toStr crashes or errors for unsigned ints
    passedStr = List.len passedTests |> Num.toI64 |> Num.toStr
    failedStr = List.len failedTests |> Num.toI64 |> Num.toStr

    _ <- Terminal.forecolor color.r color.g color.b |> Task.await
    _ <- Stdout.line "Unit tests \(resultStr). Passed=\(passedStr) Failed=\(failedStr)" |> Task.await
    
    Task.succeed {}