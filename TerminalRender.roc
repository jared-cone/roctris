interface TerminalRender
    exposes [
        render,
        renderDelta,
    ]
    imports [
        Color.{Rgb8},
        pf.Stdout,
        pf.Task.{Task},
        pf.Terminal,
        View.{View, Cell},
    ]
    
RenderTask : Task {} []

ViewRenderState : {
    width : Nat,
    tasks : List RenderTask,
    x : Nat,
    y : Nat,
    foreColor : Rgb8,
    backColor : Rgb8,
}

addCommand : List RenderTask, RenderTask -> List RenderTask
addCommand = \tasks, task ->
    List.append tasks task
    
addCommandIf : List RenderTask, Bool, RenderTask -> List RenderTask
addCommandIf = \tasks, bool, task ->
    if bool then List.append tasks task else tasks

addNextViewCommands : ViewRenderState, Cell -> ViewRenderState
addNextViewCommands = \state, cell ->
    foreColor = cell.foreColor
    backColor = cell.backColor
    
    endOfLine = (state.x + 1) >= state.width
    foreColorChanged = foreColor != state.foreColor
    backColorChanged = backColor != state.backColor
    
    {x, y} =
        if endOfLine then
            {x : 0, y : state.y + 1}
        else
            {x : state.x + 1, y : state.y}
    
    tasks = state.tasks
        |> addCommandIf foreColorChanged (Terminal.forecolor foreColor.r foreColor.g foreColor.b)
        |> addCommandIf backColorChanged (Terminal.backcolor backColor.r backColor.g backColor.b)
        |> addCommand (Stdout.put cell.grapheme)
        |> addCommandIf endOfLine (Terminal.goto x y)

    {state & x, y, tasks, foreColor, backColor}
    
addViewCommands : List RenderTask, View -> List RenderTask
addViewCommands = \tasks, view ->
    # TODO compiler didn't like this
    #x = 0
    #y = 0
    #width = view.width
    #foreColor = Color.black
    #backColor = Color.black
    #state = {x, y, width, tasks, foreColor, backColor}
    
    foreColor = Color.black |> Color.toRgb8
    backColor = foreColor
    
    state : ViewRenderState
    state = {width : view.width, tasks, x : 0, y : 0, foreColor, backColor}
    
    List.walk view.cells state addNextViewCommands
    |> .tasks

render : View -> Task {} []
render = \view ->
    []
    |> addCommand (Terminal.goto 0 0)
    |> addCommand (Terminal.color 0 0 0 0 0 0)
    |> addViewCommands view
    |> addCommand (Stdout.line "")
    |> Task.fromList
    
DeltaViewRenderState : {
    width : Nat,
    oldCells : List Cell,
    tasks : List RenderTask,
    idx : Nat,                  # TODO would be nice to have List.walkWithIndex
    x : Nat,
    y : Nat,
    foreColor : Rgb8,
    backColor : Rgb8,
}
    
renderDeltaLoop : DeltaViewRenderState, Cell -> DeltaViewRenderState
renderDeltaLoop = \state, cell ->
    y = Num.divTruncChecked state.idx state.width |> Result.withDefault 0
    x = state.idx - (y * state.width)
    
    oldCell = List.get state.oldCells state.idx |> Result.withDefault cell

    if cell == oldCell then
        {state & idx : state.idx + 1}
    else
        foreColor = cell.foreColor
        backColor = cell.backColor

        foreColorChanged = foreColor != state.foreColor
        backColorChanged = backColor != state.backColor
        positionChanged = y != state.y || x != (state.x + 1)

        tasks = state.tasks
            |> addCommandIf positionChanged (Terminal.goto x y)
            |> addCommandIf foreColorChanged (Terminal.forecolor foreColor.r foreColor.g foreColor.b)
            |> addCommandIf backColorChanged (Terminal.backcolor backColor.r backColor.g backColor.b)
            |> addCommand (Stdout.put cell.grapheme)

        {state & idx : state.idx + 1, tasks, x, y, foreColor, backColor}

addDeltaViewCommands : List RenderTask, View, View -> List RenderTask
addDeltaViewCommands = \tasks, oldView, view ->
    foreColor = Color.black |> Color.toRgb8
    backColor = foreColor
    
    state : DeltaViewRenderState
    state = {width : view.width, oldCells : oldView.cells, tasks, idx : 0, x : 0, y : 0, foreColor, backColor}

    List.walk view.cells state renderDeltaLoop
    |> .tasks
    
renderDelta : View, View -> Task {} []
renderDelta = \oldView, view ->
    if oldView.width != view.width || oldView.height != view.height then
        render view
    else
        []
        |> addCommand (Terminal.goto 0 0)
        |> addCommand (Terminal.color 0 0 0 0 0 0)
        |> addDeltaViewCommands oldView view
        |> addCommand (Stdout.line "")
        |> Task.fromList