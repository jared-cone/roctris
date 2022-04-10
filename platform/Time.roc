interface Time
    exposes [ appSeconds ]
    imports [ pf.Effect, Task.{Task} ]

appSeconds : Task F64 *
appSeconds = Effect.after Effect.timeAppSeconds Task.succeed