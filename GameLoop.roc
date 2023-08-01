interface GameLoop
    exposes [
        Message,
        run,
    ]
    imports [
        Keys,
        pf.Task,
        pf.Terminal,
        pf.Thread,
        pf.Time,
        TerminalRender,
        Util,
        View.{View},
    ]
    
Message : [Key Str, Tick F32]

Update m : m, Message -> m

Draw m : m -> View
    
State m : {
    model : m,
    view : View,
    update : Update m,
    draw : Draw m,
}

run : m, Update m, Draw m -> Task.Task {} []
run = \model, update, draw ->
    _ <- Terminal.clear |> Task.await
    _ <- Terminal.rawMode Bool.true |> Task.await
    _ <- Terminal.cursorVisible Bool.false |> Task.await
    
    view = draw model
    
    _ <- TerminalRender.render view |> Task.await
   
    state : State m
    state = {model, view, update, draw}

    _ <- Task.loop state loop |> Task.await
    
    _ <- Terminal.backcolorReset |> Task.await
    _ <- Terminal.forecolorReset |> Task.await
    _ <- Terminal.clear |> Task.await
    _ <- Terminal.rawMode Bool.false |> Task.await
    _ <- Terminal.cursorVisible Bool.true |> Task.await
    
    Task.succeed {}
    
updateInput = \model, state, key ->
    #if key != "" then
        state.update model (Key key)
    #else
    #    model
        
tick = \model, state, deltaSeconds -> state.update model (Tick deltaSeconds)

loop : State m -> Task.Task [Step (State m), Done {}] []
loop = \state ->
    frameStartTime <- Time.appSeconds |> Task.await
    
    # TODO tried adding a fixedDeltaSeconds as input to Run and into State, but compiler kept crashing
    fixedDeltaSeconds = (1/60)

    # TODO read more than one key
    key <- Terminal.nextKey |> Task.await

    model =
        state.model
        |> updateInput state key
        |> tick state fixedDeltaSeconds
        
    #viewStartTime <- Time.appSeconds |> Task.await
        
    view = state.draw model
    
    #renderStartTime <- Time.appSeconds |> Task.await
    
    _ <- TerminalRender.renderDelta state.view view |> Task.await
    
    frameEndTime <- Time.appSeconds |> Task.await
    
    frameTime = Num.toF64(frameEndTime - frameStartTime)
    
    sleepTime = Util.max 0 (Num.toF64(fixedDeltaSeconds) - frameTime)

    _ <- Thread.sleep (Num.toF64 sleepTime) |> Task.await
    
    if (key == Keys.q) || (key == Keys.exit) then
        Done {} |> Task.succeed
    else
        Step {state & model, view} |> Task.succeed