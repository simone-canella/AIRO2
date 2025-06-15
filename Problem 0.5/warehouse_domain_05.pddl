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
    (to_load ?obj - crate)
    (freeLoader ?ld - loader)
    (loadingCrate ?ld - loader ?obj - crate)
    (at ?obj - crate ?loc - location)
    (onBelt ?obj - crate)
    (at-loader ?ld - loader ?loc - location)
      (moving-loaded ?rob - mover ?from - location ?to - location)
    (movingfree ?mover - mover ?from - location ?to - location)
    (carryingcratedouble ?rob1 - mover ?rob2 - mover ?obj - crate)
    (moving-loaded-double ?rob1 - mover ?rob2 - mover ?from - location ?to - location)
)

  (:functions
    (weight ?obj - crate)
    (distance ?from - location ?to - location)
    (travel_time ?rob - mover)
    (loading_time ?ld - loader)
    (doublecarry ?obj - crate)
)

  ;; crate pick-up
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

  ;; Light crate carrying
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
      (moving-loaded ?rob ?from ?to)
      (not (at-robby ?rob ?from))
      (assign (travel_time ?rob) 0)
      (inTransit ?obj))
  )

  (:process carrying
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?to - location)
    :precondition (and (not (= ?rob1 ?rob2)) (inTransit ?obj) (moving-loaded ?rob1 ?from ?to) (carryingCrate ?rob1 ?obj) (not (linkedWith ?rob1 ?rob2)))
    :effect (increase (travel_time ?rob1) (* #t 1))
  )

  (:event endCarrying
    :parameters (?rob - mover ?obj - crate ?from - location ?to - location ?ld - loader)
    :precondition (and
      (carryingCrate ?rob ?obj)
      (inTransit ?obj)
      (freeLoader ?ld)
      (moving-loaded ?rob ?from ?to)
      (>= (travel_time ?rob) (/ (* (weight ?obj) (distance ?from ?to)) 100)))
    :effect (and
      (not (carryingCrate ?rob ?obj))
      (freeMover ?rob)
      (not (inTransit ?obj))
      (at ?obj ?to)
      (at-robby ?rob ?to)
      (assign (travel_time ?rob) 0)
      (to_load ?obj)
      (not (freeLoader ?ld))
      (not (moving-loaded ?rob ?from ?to))
        )
    )






  ;; Azione di movimento libero
  (:action move
    :parameters (?mover - mover ?from - location ?to - location)
    :precondition (and
      (at-robby ?mover ?from)
      (freeMover ?mover)
      (not (= ?from ?to)))
    :effect (and
      (not (at-robby ?mover ?from))
      (movingFree ?mover ?from ?to)
      (assign (travel_time ?mover) 0))
  )

  ;; Processo di movimento libero
  (:process moving
    :parameters (?mover - mover ?from - location ?to - location)
    :precondition (movingFree ?mover ?from ?to)
    :effect (increase (travel_time ?mover) (* #t 1))
  )

  ;; Evento di arrivo a destinazione (mover libero)
  (:event endMoving 
    :parameters (?mover - mover ?from - location ?to - location)
    :precondition (and
      (movingFree ?mover ?from ?to)
      (>= (travel_time ?mover) (/ (distance ?from ?to) 10)))
    :effect (and
      (not (movingFree ?mover ?from ?to))
      (freeMover ?mover)
      (at-robby ?mover ?to)
      (assign (travel_time ?mover) 0))
  )
  

;; Double crate pick-up and carrying

  (:action pickUpDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
    :precondition (and
      (at ?obj ?loc)
      (at-robby ?rob1 ?loc)
      (at-robby ?rob2 ?loc)
      (freeMover ?rob1)
      (freeMover ?rob2)
      (not (= ?rob1 ?rob2))
      (not (pickedFrom ?obj ?loc)) ; if the crate is fragile, it has to be picked up by two movers
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
      (assign (travel_time ?rob1) 0)
      (assign (travel_time ?rob2) 0)
      (inTransit ?obj)
      (moving-loaded-double ?rob1 ?rob2 ?from ?to)
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
      (moving-loaded-double ?rob1 ?rob2 ?from ?to)
      (linkedWith ?rob1 ?rob2)
      )
    :effect (and
      (increase (travel_time ?rob1) (* #t 1))
      (increase (travel_time ?rob2) (* #t 1))
  )
  )

  (:event endCarryingDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?to - location ?ld - loader) 
    :precondition (and
      (not (= ?rob1 ?rob2))
      (linkedWith ?rob1 ?rob2)
      (carryingCrateDouble ?rob1 ?rob2 ?obj)
      (moving-loaded-double ?rob1 ?rob2 ?from ?to)
      (inTransit ?obj)
      (freeLoader ?ld)
      (>= (travel_time ?rob1) (/ (* (weight ?obj) (distance ?from ?to)) (doubleCarry ?obj)))
      (>= (travel_time ?rob2) (/ (* (weight ?obj) (distance ?from ?to)) (doubleCarry ?obj)))
    )
    :effect (and
      (not (carryingCrateDouble ?rob1 ?rob2 ?obj))
      (not (linkedWith ?rob1 ?rob2))
      (freeMover ?rob1)
      (freeMover ?rob2)
      (at ?obj ?to)
      (at-robby ?rob1 ?to)
      (at-robby ?rob2 ?to)
      (assign (travel_time ?rob1) 0)
      (assign (travel_time ?rob2) 0)
      (not (inTransit ?obj))
      (to_load ?obj)
      (not (freeLoader ?ld))
      (not (moving-loaded-double ?rob1 ?rob2 ?from ?to))
      )
  )




  ;; Loader actions
  (:action startLoading
    :parameters (?ld - loader ?obj - crate ?loc - location)
    :precondition (and
      (to_load ?obj)
      (at ?obj ?loc)
      (not (freeLoader ?ld)))
    :effect (and
      (loadingCrate ?ld ?obj)
      (not (freeLoader ?ld))
      (not (to_load ?obj))
      (not (at ?obj ?loc))
      (assign (loading_time ?ld) 0))
  )

  (:process loadingProcess
    :parameters (?ld - loader ?obj - crate)
    :precondition (loadingCrate ?ld ?obj)
    :effect (increase (loading_time ?ld) (* #t 1))
  )

  (:event endLoading
    :parameters (?ld - loader ?obj - crate)
    :precondition (and
      (loadingCrate ?ld ?obj)
      (>= (loading_time ?ld) 4))
    :effect (and
      (not (loadingCrate ?ld ?obj))
      (freeLoader ?ld)
      (onBelt ?obj)
      (assign (loading_time ?ld) 0)
      ))
)


