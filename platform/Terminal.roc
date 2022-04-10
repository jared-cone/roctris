interface Terminal
    exposes [
        rawMode,
        clear,
        cursorVisible,
        goto,
        nextKey,
        forecolor,
        forecolorReset,
        backcolor,
        backcolorReset,
        color,
    ]
    imports [ pf.Effect, Task ]
    
rawMode = \raw -> Effect.map (Effect.terminalRawMode raw) (\_ -> Ok {})
    
clear = Effect.map (Effect.terminalClear {}) (\_ -> Ok {})

cursorVisible = \visible -> Effect.map (Effect.terminalSetCursorVisible visible) (\_ -> Ok {})

goto = \x, y -> Effect.map (Effect.terminalGoto (Num.toU16 x) (Num.toU16 y)) (\_ -> Ok {})

nextKey : Task.Task Str *
nextKey = Effect.after Effect.terminalNextKey Task.succeed

forecolor = \r, g, b -> Effect.map (Effect.terminalForecolor r g b) (\_ -> Ok {})
forecolorReset = Effect.map Effect.terminalForecolorReset (\_ -> Ok {})
backcolor = \r, g, b -> Effect.map (Effect.terminalBackcolor r g b) (\_ -> Ok {})
backcolorReset = Effect.map Effect.terminalBackcolorReset (\_ -> Ok {})

color = \fr, fg, fb, br, bg, bb ->
    _ <- forecolor fr fg fb |> Task.await
    backcolor br bg bb