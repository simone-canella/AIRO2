(define (domain warehouse_domain)
  (:requirements :strips :typing :fluents :durative-actions :timed-initial-literals :conditional-effects :negative-preconditions :duration-inequalities :equality :disjunctive-preconditions :time)
  (:types mover loader crate location)
  
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
    (carried ?obj - crate)
    (at-loader ?ld - loader ?loc - location)
  )

  (:functions
    (weight ?obj - crate)
    (distance ?from - location ?to - location)
    (travel_time ?rob - mover)
    (loading_time ?ld - loader)
  )

  ;; Light crate pick-up
  (:action pickUpLight
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



  ;; Free mover movement
  (:action start_move
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

  (:process moving_process
    :parameters (?rob - mover ?from - location ?to - location)
    :precondition (moving ?rob ?from ?to)
    :effect (increase (travel_time ?rob) (* #t 1))
  )

  (:event end_move
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

  ;; Light crate carrying
  (:action start_carry_light
    :parameters (?rob - mover ?obj - crate ?from - location)
    :precondition (and
      (< (weight ?obj) 50)
      (carryingCrate ?rob ?obj)
      (pickedFrom ?obj ?from)
      (not (inTransit ?obj)))
    :effect (and
      (not (at-robby ?rob ?from))
      (assign (travel_time ?rob) 0)
      (inTransit ?obj)
      (moving ?rob ?from loadingBay))
  )

  (:process carrying_light
    :parameters (?rob - mover ?obj - crate ?from - location)
    :precondition (inTransit ?obj)
    :effect (increase (travel_time ?rob) (* #t 1))
  )

  (:event end_carrying_light
    :parameters (?rob - mover ?obj - crate ?from - location)
    :precondition (and
      (carryingCrate ?rob ?obj)
      (inTransit ?obj)
      (>= (travel_time ?rob) (/ (* (weight ?obj) (distance ?from loadingBay)) 100)))
    :effect (and
      (not (carryingCrate ?rob ?obj))
      (freeMover ?rob)
      (not (inTransit ?obj))
      (at ?obj loadingBay)
      (at-robby ?rob loadingBay)
      (assign (travel_time ?rob) 0)
      (to_load ?obj)
    ))



  ;; Heavy crate carrying
    (:action pickUpHeavy
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
    :precondition (and
      (at ?obj ?loc)
      (at-robby ?rob1 ?loc)
      (at-robby ?rob2 ?loc)
      (freeMover ?rob1)
      (freeMover ?rob2)
      (>= (weight ?obj) 50)
      (not (= ?rob1 ?rob2))
      (not (pickedFrom ?obj ?loc))
    )
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

  (:action start_carry_heavy
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

  (:process carrying_heavy
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

  (:event end_carrying_heavy
    :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?from - location)
    :precondition (and
      (carryingCrate ?rob1 ?obj)
      (carryingCrate ?rob2 ?obj)
      (inTransit ?obj)
      (>= (travel_time ?rob1) (/ (* (weight ?obj) (distance ?from loadingBay)) 150))
      (>= (travel_time ?rob2) (/ (* (weight ?obj) (distance ?from loadingBay)) 150)))
    :effect (and
      (not (carryingCrate ?rob1 ?obj))
      (not (carryingCrate ?rob2 ?obj))
      (freeMover ?rob1)
      (freeMover ?rob2)
      (at ?obj loadingBay)
      (at-robby ?rob1 loadingBay)
      (at-robby ?rob2 loadingBay)
      (assign (travel_time ?rob1) 0)
      (assign (travel_time ?rob2) 0)
      (not (inTransit ?obj))
      (to_load ?obj))
  )

  ;; Loader actions
  (:action start_loading
    :parameters (?ld - loader ?obj - crate)
    :precondition (and
      (at-loader ?ld loadingBay)
      (to_load ?obj)
      (at ?obj loadingBay)
      (freeLoader ?ld))
    :effect (and
      (loadingCrate ?ld ?obj)
      (not (freeLoader ?ld))
      (not (to_load ?obj))
      (not (at ?obj loadingBay))
      (assign (loading_time ?ld) 0))
  )

  (:process loading_process
    :parameters (?ld - loader ?obj - crate)
    :precondition (loadingCrate ?ld ?obj)
    :effect (increase (loading_time ?ld) (* #t 1))
  )

  (:event end_loading
    :parameters (?ld - loader ?obj - crate)
    :precondition (and
      (loadingCrate ?ld ?obj)
      (>= (loading_time ?ld) 4))
    :effect (and
      (not (loadingCrate ?ld ?obj))
      (freeLoader ?ld)
      (onBelt ?obj)
      (assign (loading_time ?ld) 0)))
)

;;TO DO: CREATE ACTIO-PROCESS-EVENT FOR LIGHT CRATE DOUBLE PICK-UP AND DOUBLE CARRYING
