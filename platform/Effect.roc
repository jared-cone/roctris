hosted Effect
    exposes [
        Effect, after, map, always, forever, loop, putLine, put, getLine,
        terminalRawMode,
        terminalClear,
        terminalSetCursorVisible,
        terminalGoto,
        terminalNextKey,
        terminalForecolor,
        terminalForecolorReset,
        terminalBackcolor,
        terminalBackcolorReset,
        sleep,
        randomU32,
        timeAppSeconds,
    ]
    imports []
    generates Effect with [ after, map, always, forever, loop ]

putLine : Str -> Effect {}

put : Str -> Effect {}

getLine : Effect Str

terminalRawMode : Bool -> Effect {}

terminalClear : {} -> Effect.Effect {}

terminalSetCursorVisible : Bool -> Effect {}

terminalGoto : U16, U16 -> Effect {}

# TODO would be nice to pass back a proper key struct instead of a string
#KeyType : [Char, Ctrl]
#Key : {text:Str, type:KeyType}

terminalNextKey : Effect Str

sleep : F64 -> Effect {}

terminalForecolor : U8, U8, U8 -> Effect {}
terminalForecolorReset : Effect.Effect {}
terminalBackcolor : U8, U8, U8 -> Effect {}
terminalBackcolorReset : Effect.Effect {}

randomU32 : Effect U32

timeAppSeconds : Effect F64