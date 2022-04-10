interface Thread
    exposes [ sleep ]
    imports [ pf.Effect, Task.{Task} ]

sleep : F64 -> Task {} *
sleep = \seconds -> Effect.map (Effect.sleep seconds) (\_ -> Ok {})