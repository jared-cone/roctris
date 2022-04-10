interface Stdout
    exposes [ line, put ]
    imports [ pf.Effect, Task.{ Task } ]

line : Str -> Task {} *
line = \str -> Effect.map (Effect.putLine str) (\_ -> Ok {})

put : Str -> Task {} *
put = \str -> Effect.map (Effect.put str) (\_ -> Ok {})