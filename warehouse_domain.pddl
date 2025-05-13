(define (domain warehouse_domain)

; remove requirements that are not needed
(:requirements :strips :typing :durative-actions :numeric-fluents :negative-preconditions)

(:types 
    mover loader crate location
)

(:predicates 
    (to_load ?c - crate)
    (heavy ?c - crate)
    (light ?c - crate)
    (carry ?m - mover ?c - crate)
    (freeMover ?m - mover)
    (freeLoader ?l - loader)
    (loading ?l - loader ?c - crate)
    (at_robby ?m - mover ?l - location)
    (at_crate ?c - crate ?l - location)
    (groupA ?c - crate)
    (on_belt ?c - crate ?l - location)
)

(:functions
    (loading_duration) ; duration of loading a crate
    (weight ?c - crate) ; weight of a crate
    (distance ?from - location ?to - location) ; distance between two locations
)


(:action pick-up-heavy
    :parameters (?m1 - mover ?m2 - mover ?l - location ?c - crate)
    :precondition (and (freeMover ?m1) (freeMover ?m2) (at_robby ?m1 ?l) (at_robby ?m2 ?l) (heavy ?c) (at_crate ?c ?l))
    :effect (and (not (freeMover ?m1)) (not (freeMover ?m2)) (carry ?m1 ?c) (carry ?m2 ?c))
)

(:action pick-up-light-single
    :parameters (?m - mover ?l - location ?c - crate)
    :precondition (and (freeMover ?m) (at_robby ?m ?l) (light ?c) (at_crate ?c ?l))
    :effect (and (not (freeMover ?m)) (carry ?m ?c))
)

(:action pick-up-light-double
    :parameters (?m1 - mover ?m2 - mover ?l - location ?c - crate)
    :precondition (and (freeMover ?m1) (freeMover ?m2) (at_robby ?m1 ?l) (at_robby ?m2 ?l) (light ?c) (at_crate ?c ?l))
    :effect (and (not (freeMover ?m1)) (not (freeMover ?m2)) (carry ?m1 ?c) (carry ?m2 ?c))
)

(:action drop-off_heavy
    :parameters (?m1 - mover ?m2 - mover ?l - location ?c - crate ?ld - loader)
    :precondition (and (carry ?m1 ?c) (carry ?m2 ?c) (at_robby ?m1 ?l) (at_robby ?m2 ?l) (heavy ?c) (not(loading ?l ?c)))
    :effect (and (not (carry ?m1 ?c)) (not (carry ?m2 ?c)) (at_robby ?m1 ?l) (at_robby ?m2 ?l) (at_crate ?c ?l) (to_load ?c) (freeMover ?m1) (freeMover ?m2) )
)

(:action drop-off-light-single
    :parameters (?m - mover ?l - location ?c - crate ?ld - loader)
    :precondition (and (carry ?m ?c) (at_robby ?m ?l) (light ?c) (not(loading ?l ?c)))
    :effect (and (not (carry ?m ?c)) (at_robby ?m ?l) (at_crate ?c ?l) (to_load ?c) (freeMover ?m) )
)

(:action drop-off-light-double
    :parameters (?m1 - mover ?m2 - mover ?l - location ?c - crate ?ld - loader)
    :precondition (and (carry ?m1 ?c) (carry ?m2 ?c) (at_robby ?m1 ?l) (at_robby ?m2 ?l) (light ?c) (not(loading ?l ?c)))
    :effect (and (not (carry ?m1 ?c)) (not (carry ?m2 ?c)) (at_robby ?m1 ?l) (at_robby ?m2 ?l) (at_crate ?c ?l) (to_load ?c) (freeMover ?m1) (freeMover ?m2) )
)

(:durative-action loading_crate
    :parameters (?ld - loader ?c - crate ?l - location)
    :duration (=?duration (loading_duration))
    :condition (and (at start (to_load ?c)) (at start (freeLoader ?ld)))
    :effect (and (at start (loading ?ld ?c)) (at end (not (to_load ?c))) (at end (on_belt ?c ?l))(at end(freeLoader ?ld)) )
)

(:durative-action moving_heavy_crate
    :parameters (?m1 - mover ?m2 - mover ?c - crate ?from - location ?to - location)
    :duration (= ?duration (/ (* (weight ?c) (distance ?from ?to)) 100))
    :condition (and (over all (carry ?m1 ?c)) (over all (carry ?m2 ?c)) (over all (heavy ?c)) (at start (at_robby ?m1 ?from)) (at start (at_robby ?m2 ?from))(at start(at_crate ?c ?from)))
    :effect (and (at start(not(at_crate ?c ?from))) (at start(not(at_robby ?m1 ?from))) (at start(not(at_robby ?m2 ?from))) (at end (at_robby ?m1 ?to)) (at end (at_robby ?m2 ?to))(at end(at_crate ?c ?to)) )
)


(:durative-action moving_light_crate
    :parameters (?m - mover ?c - crate ?from - location ?to - location)
    :duration (= ?duration (/ (* (weight ?c) (distance ?from ?to)) 100))
    :condition (and (over all (carry ?m ?c)) (at start (at_robby ?m ?from)) (over all (light ?c)) (at start (at_crate ?c ?from)))
    :effect (and (at end (at_robby ?m ?to)) (at end (at_crate ?c ?to)) (at start (not (at_crate ?c ?from))) (at start (not (at_robby ?m ?from))) )
)

(:durative-action moving_light_crate_double
    :parameters (?m1 - mover ?m2 - mover ?c - crate ?from - location ?to - location)
    :duration (= ?duration (/ (* (weight ?c) (distance ?from ?to)) 150))
    :condition (and (over all (carry ?m1 ?c)) (over all (carry ?m2 ?c)) (at start (at_robby ?m1 ?from)) (at start (at_robby ?m2 ?from)) (over all (light ?c)) (at start (at_crate ?c ?from)))
    :effect (and (at end (at_robby ?m1 ?to)) (at end (at_robby ?m2 ?to)) (at end (at_crate ?c ?to)) (at start (not (at_crate ?c ?from))) (at start (not (at_robby ?m1 ?from))) (at start (not (at_robby ?m2 ?from))) )
)

(:durative-action moving_free
    :parameters (?m - mover ?from - location ?to - location ?c - crate)
    :duration (= ?duration (/(distance ?from ?to)10))
    :condition (and (at start (at_robby ?m ?from)) (at start (not (at_crate ?m ?from)))(over all (not (carry ?m ?c))) )
    :effect (and (at end (at_robby ?m ?to)) (at start (not (at_robby ?m ?from))) )
)

)
