(define (domain warehouse_domain_05)
  (:requirements :strips :typing :fluents :durative-actions :timed-initial-literals :conditional-effects :negative-preconditions :duration-inequalities :equality :disjunctive-preconditions :time)
  (:types mover loader crate location)
  

  (:predicates
    (at-robby ?rob - mover ?loc - location)
    (freeMover ?rob - mover)
    (carryingCrate ?rob - mover ?obj - crate)
    (linkedWith ?rob1 - mover ?rob2 - mover)
    (pickedFrom ?obj - crate ?loc - location)
    (inTransit ?obj - crate)
    (toLoad ?obj - crate)
    (freeLoader ?ld - loader)
    (loadingCrate ?ld - loader ?obj - crate)
    (at ?obj - crate ?loc - location)
    (onBelt ?obj - crate)
    (at-loader ?ld - loader ?loc - location)
    (movingLoaded ?rob - mover ?from - location ?to - location)
    (movingfree ?mover - mover ?from - location ?to - location)
    (carryingCrateDouble ?rob1 - mover ?rob2 - mover ?obj - crate)
    (movingLoadedDouble ?rob1 - mover ?rob2 - mover ?from - location ?to - location)
)

  (:functions
    (weight ?obj - crate)
    (distance ?from - location ?to - location)
    (travelTime ?rob - mover)
    (loadingTime ?ld - loader)
    (doublecarry ?obj - crate)
  )

  ;; Move robot without a load
  (:action move
    :parameters (?mover - mover ?from - location ?to - location)
    :precondition (and
      (at-robby ?mover ?from)
      (freeMover ?mover)
      (not (= ?from ?to)))
    :effect (and
      (not (at-robby ?mover ?from))
      (movingFree ?mover ?from ?to)
      (assign (travelTime ?mover) 0))
  )

  (:process moving
    :parameters (?mover - mover ?from - location ?to - location)
    :precondition (movingFree ?mover ?from ?to)
    :effect (increase (travelTime ?mover) (* #t 1))
  )

  (:event endMoving 
    :parameters (?mover - mover ?from - location ?to - location)
    :precondition (and
      (movingFree ?mover ?from ?to)
      (>= (travelTime ?mover) (/ (distance ?from ?to) 10)))
    :effect (and
      (not (movingFree ?mover ?from ?to))
      (freeMover ?mover)
      (at-robby ?mover ?to)
      (assign (travelTime ?mover) 0))
  )

  ;; Transportation of a light crate by one robot
  (:action pickUp
    :parameters (?rob - mover ?obj - crate ?loc - location)
    :precondition (and
      (at ?obj ?loc)
      (at-robby ?rob ?loc)
      (freeMover ?rob)
      (< (weight ?obj) 50)
      (not (pickedFrom ?obj ?loc))
    )
    :effect (and
      (carryingCrate ?rob ?obj)
      (not (freeMover ?rob))
      (not (at ?obj ?loc))
      (pickedFrom ?obj ?loc)
    )
  )

  (:action startCarry
    :parameters (?rob - mover ?obj - crate ?from - location ?to - location ?ld - loader)
    :precondition (and
      (< (weight ?obj) 50)
      (carryingCrate ?rob ?obj)
      (at-robby ?rob ?from)
      (pickedFrom ?obj ?from)
      (freeLoader ?ld))
    :effect (and
      (not (freeMover ?rob))
      (movingLoaded ?rob ?from ?to)
      (not (at-robby ?rob ?from))
      (assign (travelTime ?rob) 0)
      (inTransit ?obj))
  )

  (:process carrying
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?to - location)
    :precondition (and (not (= ?rob1 ?rob2)) (inTransit ?obj) (movingLoaded ?rob1 ?from ?to) (carryingCrate ?rob1 ?obj) (not (linkedWith ?rob1 ?rob2)))
    :effect (increase (travelTime ?rob1) (* #t 1))
  )

  (:event endCarrying
    :parameters (?rob - mover ?obj - crate ?from - location ?to - location ?ld - loader)
    :precondition (and
      (carryingCrate ?rob ?obj)
      (inTransit ?obj)
      (freeLoader ?ld)
      (movingLoaded ?rob ?from ?to)
      (>= (travelTime ?rob) (/ (* (weight ?obj) (distance ?from ?to)) 100)))
    :effect (and
      (not (carryingCrate ?rob ?obj))
      (freeMover ?rob)
      (not (inTransit ?obj))
      (at ?obj ?to)
      (at-robby ?rob ?to)
      (assign (travelTime ?rob) 0)
      (toLoad ?obj)
      (not (freeLoader ?ld))
      (not (movingLoaded ?rob ?from ?to))
        )
    )

  ;; Transportation of a crate by two robots
  (:action pickUpDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
    :precondition (and
      (at ?obj ?loc)
      (at-robby ?rob1 ?loc)
      (at-robby ?rob2 ?loc)
      (freeMover ?rob1)
      (freeMover ?rob2)
      (not (= ?rob1 ?rob2))
      (not (pickedFrom ?obj ?loc))
    )
    :effect (and
      (carryingCrateDouble ?rob1 ?rob2 ?obj)
      (not (freeMover ?rob1))
      (not (freeMover ?rob2))
      (linkedWith ?rob1 ?rob2)
      (not (at ?obj ?loc))
      (pickedFrom ?obj ?loc)

    )
  )

  (:action startCarryDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?to - location ?ld - loader)
    :precondition (and
      (not (inTransit ?obj))
      (not (= ?rob1 ?rob2))
      (not (freeMover ?rob1))
      (not (freeMover ?rob2))
      (freeLoader ?ld)
      (carryingCrateDouble ?rob1 ?rob2 ?obj)
      (pickedFrom ?obj ?from)
      (linkedWith ?rob1 ?rob2)
    )
    :effect (and
      (not (at-robby ?rob1 ?from))
      (not (at-robby ?rob2 ?from))
      (assign (travelTime ?rob1) 0)
      (assign (travelTime ?rob2) 0)
      (inTransit ?obj)
      (movingLoadedDouble ?rob1 ?rob2 ?from ?to)
      (not (freeMover ?rob1))
      (not (freeMover ?rob2))
      (not (movingFree ?rob1 ?from ?to))
      (not (movingFree ?rob2 ?from ?to))
    )
  )

  (:process carryingDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?to - location)
    :precondition (and
      (not (= ?rob1 ?rob2))
      (not (freeMover ?rob1))
      (not (freeMover ?rob2))
      (carryingCrateDouble ?rob1 ?rob2 ?obj)
      (inTransit ?obj)
      (movingLoadedDouble ?rob1 ?rob2 ?from ?to)
      (linkedWith ?rob1 ?rob2)
      )
    :effect (and
      (increase (travelTime ?rob1) (* #t 1))
      (increase (travelTime ?rob2) (* #t 1))
  )
  )

  (:event endCarryingDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?to - location ?ld - loader) 
    :precondition (and
      (not (= ?rob1 ?rob2))
      (linkedWith ?rob1 ?rob2)
      (carryingCrateDouble ?rob1 ?rob2 ?obj)
      (movingLoadedDouble ?rob1 ?rob2 ?from ?to)
      (inTransit ?obj)
      (freeLoader ?ld)
      (>= (travelTime ?rob1) (/ (* (weight ?obj) (distance ?from ?to)) (doubleCarry ?obj)))
      (>= (travelTime ?rob2) (/ (* (weight ?obj) (distance ?from ?to)) (doubleCarry ?obj)))
    )
    :effect (and
      (not (carryingCrateDouble ?rob1 ?rob2 ?obj))
      (not (linkedWith ?rob1 ?rob2))
      (freeMover ?rob1)
      (freeMover ?rob2)
      (at ?obj ?to)
      (at-robby ?rob1 ?to)
      (at-robby ?rob2 ?to)
      (assign (travelTime ?rob1) 0)
      (assign (travelTime ?rob2) 0)
      (not (inTransit ?obj))
      (toLoad ?obj)
      (not (freeLoader ?ld))
      (not (movingLoadedDouble ?rob1 ?rob2 ?from ?to))
      )
  )

  ;; Load crate on the conveyor belt
  (:action startLoading
    :parameters (?ld - loader ?obj - crate ?loc - location)
    :precondition (and
      (toLoad ?obj)
      (at ?obj ?loc)
      (not (freeLoader ?ld)))
    :effect (and
      (loadingCrate ?ld ?obj)
      (not (freeLoader ?ld))
      (not (toLoad ?obj))
      (not (at ?obj ?loc))
      (assign (loadingTime ?ld) 0))
  )

  (:process loadingProcess
    :parameters (?ld - loader ?obj - crate)
    :precondition (loadingCrate ?ld ?obj)
    :effect (increase (loadingTime ?ld) (* #t 1))
  )

  (:event endLoading
    :parameters (?ld - loader ?obj - crate)
    :precondition (and
      (loadingCrate ?ld ?obj)
      (>= (loadingTime ?ld) 4))
    :effect (and
      (not (loadingCrate ?ld ?obj))
      (freeLoader ?ld)
      (onBelt ?obj)
      (assign (loadingTime ?ld) 0)
      ))
)


