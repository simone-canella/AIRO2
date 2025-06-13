(define (domain warehouse_domain)
  (:requirements :strips :typing :fluents :durative-actions :timed-initial-literals :conditional-effects :negative-preconditions :duration-inequalities :equality :disjunctive-preconditions :time)
  (:types mover loader crate location group)
  
  (:constants
    loadingBay - location
  )

  (:predicates
    (at-robby ?rob - mover ?loc - location)
    (freeMover ?rob - mover)
    (carryingCrate ?rob - mover ?obj - crate)
    (linkedWith ?rob1 - mover ?rob2 - mover)
    (moving ?rob - mover ?from - location ?to - location)
    (pickedFrom ?obj - crate ?loc - location)
    (inTransit ?obj - crate)
    (to_load ?obj - crate)
    (freeLoader ?ld - loader)
    (loadingCrate ?ld - loader ?obj - crate)
    (at ?obj - crate ?loc - location)
    (onBelt ?obj - crate)
    (at-loader ?ld - loader ?loc - location)
    (fragile ?obj - crate)
    (in-group ?obj - crate ?g - group)
    (group-active ?g - group)
    (group-done ?g - group)
)

  (:functions
    (weight ?obj - crate)
    (distance ?from - location ?to - location)
    (travel_time ?rob - mover)
    (loading_time ?ld - loader)
    (doublecarry ?obj - crate)
    (size ?g - group) ; size of the group, i.e., number of crates in the group
    (arrived ?g - group) ; how many crates of one group have been dropped off at the loading bay
)

  ;; crate pick-up
  (:action pickUp
    :parameters (?rob - mover ?obj - crate ?loc - location ?g - group)
    :precondition (and
      (not (fragile ?obj)) ; if the crate is fragile, it has to be picked up by two movers
      (at ?obj ?loc)
      (at-robby ?rob ?loc)
      (freeMover ?rob)
      (< (weight ?obj) 50)
      (not (pickedFrom ?obj ?loc))
      (in-group ?obj ?g)
      (group-active ?g)
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
    :parameters (?rob - mover ?obj - crate ?from - location ?g - group)
    :precondition (and
      (< (weight ?obj) 50)
      (carryingCrate ?rob ?obj)
      (at-robby ?rob ?from)
      (pickedFrom ?obj ?from)
      (not (inTransit ?obj))
      (group-active ?g))
    :effect (and
      (not (at-robby ?rob ?from))
      (assign (travel_time ?rob) 0)
      (inTransit ?obj)
      (moving ?rob ?from loadingBay))
  )

  (:process carrying
    :parameters (?rob - mover ?obj - crate ?from - location)
    :precondition (inTransit ?obj)
    :effect (increase (travel_time ?rob) (* #t 1))
  )

  (:event endCarrying
    :parameters (?rob - mover ?obj - crate ?from - location ?ld - loader ?g - group)
    :precondition (and
      (carryingCrate ?rob ?obj)
      (group-active ?g)
      (inTransit ?obj)
      (freeLoader ?ld)
      (>= (travel_time ?rob) (/ (* (weight ?obj) (distance ?from loadingBay)) 100)))
    :effect (and
      (not (carryingCrate ?rob ?obj))
      (freeMover ?rob)
      (not (inTransit ?obj))
      (at ?obj loadingBay)
      (at-robby ?rob loadingBay)
      (assign (travel_time ?rob) 0)
      (to_load ?obj)
      (not (freeLoader ?ld))
        )
    )
  
  (:event active-next-group
    :parameters (?g1 - group ?g2 - group)
    :precondition (and
      (group-active ?g1)
      (not (group-active ?g2))
      (= (arrived ?g1) (size ?g1))
    )
    :effect (and
      (group-active ?g2)
      (group-done ?g1)
      (not (group-active ?g1))
    )
  )









  ;; Free mover movement
  (:action startMove
    :parameters (?rob - mover ?from - location ?to - location)
    :precondition (and
      (at-robby ?rob ?from)
      (freeMover ?rob)
      (not (= ?from ?to)))
    :effect (and
      (moving ?rob ?from ?to)
      (not (at-robby ?rob ?from))
      (assign (travel_time ?rob) 0))
  )

  (:process movingProcess
    :parameters (?rob - mover ?from - location ?to - location)
    :precondition (moving ?rob ?from ?to)
    :effect (increase (travel_time ?rob) (* #t 1))
  )

  (:event endMove
    :parameters (?rob - mover ?from - location ?to - location)
    :precondition (and
      (moving ?rob ?from ?to)
      (>= (travel_time ?rob) (/ (distance ?from ?to) 10)))
    :effect (and
      (not (moving ?rob ?from ?to))
      (at-robby ?rob ?to)
      (freeMover ?rob)
      (assign (travel_time ?rob) 0))
  )

  


;; Double crate pick-up and carrying

  (:action pickUpDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location ?g - group)
    :precondition (and
      (in-group ?obj ?g)
      (group-active ?g)
      (at ?obj ?loc)
      (at-robby ?rob1 ?loc)
      (at-robby ?rob2 ?loc)
      (freeMover ?rob1)
      (freeMover ?rob2)
      (not (= ?rob1 ?rob2))
      (not (pickedFrom ?obj ?loc))) ; if the crate is fragile, it has to be picked up by two movers
    :effect (and
      (carryingCrate ?rob1 ?obj)
      (carryingCrate ?rob2 ?obj)
      (not (freeMover ?rob1))
      (not (freeMover ?rob2))
      (linkedWith ?rob1 ?rob2)
      (linkedWith ?rob2 ?rob1)
      (not (at ?obj ?loc))
      (pickedFrom ?obj ?loc)

    )
  )

  (:action startCarryDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location)
    :precondition (and
      (carryingCrate ?rob1 ?obj)
      (carryingCrate ?rob2 ?obj)
      (pickedFrom ?obj ?from)
      (linkedWith ?rob1 ?rob2)
      (not (inTransit ?obj)))
    :effect (and
      (moving ?rob1 ?from loadingBay)
      (moving ?rob2 ?from loadingBay)
      (not (at-robby ?rob1 ?from))
      (not (at-robby ?rob2 ?from))
      (assign (travel_time ?rob1) 0)
      (assign (travel_time ?rob2) 0)
      (inTransit ?obj))
  )

  (:process carryingDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location)
    :precondition (and
      (carryingCrate ?rob1 ?obj)
      (carryingCrate ?rob2 ?obj)
      (inTransit ?obj)
      (moving ?rob1 ?from loadingBay)
      (moving ?rob2 ?from loadingBay))
    :effect (and
      (increase (travel_time ?rob1) (* #t 1))
      (increase (travel_time ?rob2) (* #t 1)))
  )

  (:event endCarryingDouble
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location ?ld - loader)
    :precondition (and
      (carryingCrate ?rob1 ?obj)
      (carryingCrate ?rob2 ?obj)
      (inTransit ?obj)
      (freeLoader ?ld)
      (>= (travel_time ?rob1) (/ (* (weight ?obj) (distance ?from loadingBay)) (doubleCarry ?obj)))
      (>= (travel_time ?rob2) (/ (* (weight ?obj) (distance ?from loadingBay)) (doubleCarry ?obj))))
    :effect (and
      (not (carryingCrate ?rob1 ?obj))
      (not (carryingCrate ?rob2 ?obj))
      (not (linkedWith ?rob1 ?rob2))
      (not (linkedWith ?rob2 ?rob1))
      (freeMover ?rob1)
      (freeMover ?rob2)
      (at ?obj loadingBay)
      (at-robby ?rob1 loadingBay)
      (at-robby ?rob2 loadingBay)
      (assign (travel_time ?rob1) 0)
      (assign (travel_time ?rob2) 0)
      (not (inTransit ?obj))
      (to_load ?obj)
      (not (freeLoader ?ld))
      )
  )


  ;; Loader actions
  (:action startLoading
    :parameters (?ld - loader ?obj - crate)
    :precondition (and
      (at-loader ?ld loadingBay)
      (to_load ?obj)
      (at ?obj loadingBay)
      (not (freeLoader ?ld)))
    :effect (and
      (loadingCrate ?ld ?obj)
      (not (freeLoader ?ld))
      (not (to_load ?obj))
      (not (at ?obj loadingBay))
      (assign (loading_time ?ld) 0))
  )

  (:process loadingProcess
    :parameters (?ld - loader ?obj - crate)
    :precondition (loadingCrate ?ld ?obj)
    :effect (increase (loading_time ?ld) (* #t 1))
  )

  (:event endLoading
    :parameters (?ld - loader ?obj - crate  ?g - group)
    :precondition (and
      (loadingCrate ?ld ?obj)
      (or
      (and (fragile ?obj) (>= (loading_time ?ld) 6))
      (and (not (fragile ?obj)) (>= (loading_time ?ld) 4))
    ))
    :effect (and
      (not (loadingCrate ?ld ?obj))
      (freeLoader ?ld)
      (onBelt ?obj)
      (assign (loading_time ?ld) 0)
      (increase (arrived ?g) 1)
      ))
)


