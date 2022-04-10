interface Timer
    exposes [ Timer, empty, create, update, reset ]
    imports [ ]

Timer : {
    duration : F32,
    elapsed : F32,
    lapsed : Bool
}

empty : Timer
empty = { duration : 0, elapsed : 0, lapsed : False }

create : F32 -> Timer
create = \duration -> {duration : duration, elapsed : 0, lapsed : False}
#TODO crashing: create = \duration -> {empty & duration : duration}

update : Timer, F32 -> Timer
update = \timer, deltaSeconds ->
    elapsed = timer.elapsed + deltaSeconds
    if elapsed >= timer.duration then
        {timer & elapsed : elapsed - timer.duration, lapsed : True}
    else
        {timer & elapsed : elapsed, lapsed : False}
        
reset : Timer -> Timer
reset = \timer -> {timer & elapsed : 0, lapsed : False}