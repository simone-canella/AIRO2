;A warehouse uses one stationary loader robot and two mobile 
;mover robots to load crates onto a conveyor belt. Mover 
;robots transport pre-selected crates from their initial 
;positions (known by distance from the loading bay) to the 
;bay, where the loader takes 4 time units to load each crate.
;Light crates (<50kg) require one mover; heavy crates (>50kg)
;need two.
;
;ASSUMPTION: 
;loading bay is in the origin of our measurement system
;time start from zero 

(define (domain warehouse_domain)
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality :disjunctive-preconditions)

    (:types
        mover loader crate location
    )

    ; un-comment following line if constants are needed
    ;(:constants )

    ;-------
    ; PREDICATE
    ;-------
    (:predicates
        (at-robby ?rob - mover ?loc - location) ;where is the mover
        (freeMover ?rob - mover) ;mover doesn't take crate
        (carryngCrate ?rob - mover ?obj - crate) ;mover holds a crate -> specify who is the holder of a crate
        (linked ?rob - mover);identify if mover is linked 
        (linkedWith ?rob1 - mover ?rob2 - mover) ;identify with which mover is linked

        (freeLoader ?rob - loader) ;indicates that loader can load crate
        (loadingCrate ?rob -loader ?obj - crate) ;indicates that loader loads crate 

        (at ?obj - crate ?loc - location) ;where is the crate
        (carried ?obj - crate) ;crate isn't picked up

        ;TODO
        ;(reserved ?obj -crate ?rob - mover) ;a crate is reserved and only the respective mover can pick up it
    )

    ;-------
    ; FUNCTION
    ;-------
    (:functions
        (weight ?obj - crate) ; weight of a crate    
        (distance ?from ?to - location) ;distance between two location

        ;(time) ;global clock 
    )

    ;-------
    ; ACTION
    ;-------

    ;@Precondition: robot at start-location, robot doesn't holding carry
    ;@Effect: robot at end-location
    (:action moveFree
        :parameters (?rob1 - mover ?rob2 - mover ?from - location ?to - location)
        :precondition (and
            (at-robby ?rob1 ?from)
            (at-robby ?rob2 ?from)
            (freeMover ?rob1)
            (freeMover ?rob2)

            (linked ?rob1)
            (linked ?rob2)

            (linkedWith ?rob1 ?rob2)
            (linkedWith ?rob2 ?rob1)
        )
        :effect (and
            (not (at-robby ?rob1 ?from))
            (not (at-robby ?rob2 ?from))
            (at-robby ?rob1 ?to)
            (at-robby ?rob2 ?to)
        )
    )

    ; ;@Precondition: robot holding crate, carry is holded
    ; ;@Effect: robot at the end-ocation
    ; (:action moveLight
    ;     :parameters (?obj - crate?rob - mover ?from - location ?to - location)
    ;     :precondition (and
    ;         (at-robby ?rob ?from)
    ;         (not (freeMover ?rob))
    ;         (carried ?obj)
    ;         (carryngCrate ?rob ?obj)
    ;     )
    ;     :effect (and
    ;         (not (at-robby ?rob ?from))
    ;         (at-robby ?rob ?to)
    ;     )
    ; )

    ;@Precondition: robots (one if weight <= 50), robots holding crate, crate is holded
    ;@Effect: robots at the end-location
    (:action moveCrate
        :parameters (?obj - crate ?rob1 - mover ?rob2 - mover ?from - location ?to - location)
        :precondition (and 
            (at-robby ?rob1 ?from)
            (at-robby ?rob2 ?from)

            (not (freeMover ?rob1))
            (not (freeMover ?rob2))

            (carried ?obj)
            (carryngCrate ?rob1 ?obj)
            (carryngCrate ?rob2 ?obj)

            (linkedWith ?rob1 ?rob2)
            (linkedWith ?rob2 ?rob1)
            (linked ?rob1)
            (linked ?rob2)
        )
        :effect (and 
            (not (at-robby ?rob1 ?from))
            (not (at-robby ?rob2 ?from))
            (at-robby ?rob1 ?to)
            (at-robby ?rob2 ?to)
        )
    )
    

    ;@Precondition: robots (one if weight <= 50) and carry at same location, robots doesn't holding crate, crate isn't holded
    ;@Effect: robots take crate, robots are linkedWith
    (:action pickUp
        :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
        :precondition (and
            (at ?obj ?loc)
            (at-robby ?rob1 ?loc)
            (at-robby ?rob2 ?loc)

            (freeMover ?rob1)
            (freeMover ?rob2)

            (not (carried ?obj))

            (not (= ?rob1 ?rob2)) ; robots are different 

            ;WEIGHT CHECK: 
            (or
                (and 
                    (>= (weight ?obj) 50)
                    (linkedWith ?rob1 ?rob2)
                ) ;if weight >= 50, must have two movers linkedWith
                
                (and 
                    (< (weight ?obj) 50) 
                    (or (linkedWith ?rob1 ?rob2) (= ?rob1 ?rob2)) ;robots should be linkedWith (if they are different) or be the same robot 
                ) ; if light crate, can be moved by one or two movers
            )
        )
        :effect (and
            (carried ?obj)
            (carryngCrate ?rob1 ?obj)
            (carryngCrate ?rob2 ?obj)

            (not (freeMover ?rob1))
            (not (freeMover ?rob2))
        )
    )

    (:action putDown
        :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
        :precondition (and 
            (carryngCrate ?rob1 ?obj)
            (carryngCrate ?rob2 ?obj)
            (carried ?obj)

            (at-robby ?rob1 ?loc)
            (at-robby ?rob2 ?loc)

            ;WEIGHT CHECK: 
            (or
                (and 
                    (>= (weight ?obj) 50)
                    (linkedWith ?rob1 ?rob2)
                ) ;if weight >= 50, must have two movers linkedWith
                
                (and 
                    (< (weight ?obj) 50) 
                    (or (linkedWith ?rob1 ?rob2) (= ?rob1 ?rob2)) ;robots should be linkedWith (if they are different) or be the same robot 
                ) ; if light crate, can be moved by one or two movers
            )
        )
        :effect (and 
            (not (carryngCrate ?rob1 ?obj))
            (not (carryngCrate ?rob2 ?obj))
            (not (carried ?obj))

            (freeMover ?rob1)
            (freeMover ?rob2)

            (at ?obj ?loc)

            ;OPTIONAL UNLINK ACTION
            ; (when (linkedWith ?rob1 ?rob2) 
            ;     (not (linkedWith ?rob1 ?rob2))
            ; )
        )
    )
    

    ;@Precondition: robot and carry at same location, robot doesn't holding carry, carry isn't holded
    ;@Effect: robot take carry
    (:action pickUpLight
        :parameters (?obj - crate ?rob - mover ?loc - location)
        :precondition (and
            (at ?obj ?loc)
            (at-robby ?rob ?loc)
            (freeMover ?rob) ;robot doesn't hold object
            (not (carried ?obj)) ;crate isn't holded

            (<= (weight ?obj) 50)
        )
        :effect (and
            (carried ?obj)
            (carryngCrate ?rob ?obj)
            (not (freeMover ?rob))
        )
    )

    ;@Precondition: robot take carry, robot in a specific location
    ;@Effect: robot and carry at same location, robot doesn't holding carry, carry isn't holded
    (:action putDownLight
        :parameters (?obj - crate ?rob - mover ?loc - location)
        :precondition (and
            (at-robby ?rob ?loc)
            (carried ?obj)
            (carryngCrate ?rob ?obj)
            (not (freeMover ?rob))
        )
        :effect (and
            (at ?obj ?loc)
            (not (carried ?obj))
            (not (carryngCrate ?rob ?obj))
            (freeMover ?rob)
        )
    )

    ;@Precondition: robot1 and robot2 at same location, robots don't holding carry, robots are not linkedWith
    ;@Effect: robots link to eachother
    (:action linkMovers
        :parameters (?rob1 - mover ?rob2 - mover ?loc - location)
        :precondition (and
            (at-robby ?rob1 ?loc)
            (at-robby ?rob2 ?loc)

            (freeMover ?rob1)
            (freeMover ?rob2)

            (not (linked ?rob1))
            (not (linked ?rob2))
        )
        :effect (and
            (linkedWith ?rob1 ?rob2)
            (linkedWith ?rob2 ?rob1)

            (linked ?rob1)
            (linked ?rob2)
        )
    )

    ;@Precondition: robot1 and robot2 at same location, robots don't holding carry
    ;@Effect: robots unlink to eachother
    (:action unlinkMover
        :parameters (?rob1 - mover ?rob2 - mover ?loc - location)
        :precondition (and
            (linkedWith ?rob1 ?rob2)
            (linkedWith ?rob2 ?rob1)
            (linked ?rob1)
            (linked ?rob2)

            (at-robby ?rob1 ?loc)
            (at-robby ?rob2 ?loc)

            (freeMover ?rob1)
            (freeMover ?rob2)
        )
        :effect (and
            (not (linkedWith ?rob1 ?rob2))
            (not (linkedWith ?rob2 ?rob1))

            (not (linked ?rob1))
            (not (linked ?rob2))
        )
    )

    ;-------
    ; DURATIVE-ACTION
    ;-------
    ;(:durative-action move
    ;    :parameters (?rob - mover ?from - location ?to - location)
    ;    :duration (= ?duration (/ (distance ?from ?to) 10))
    ;    :condition (and
    ;        (at start (at-robby ?rob ?from)) ; robot must be at the start location at action start
    ;        (over all (freeMover ?rob)) ; robot must remain free during the entire move
    ;    )
    ;    :effect (and
    ;        (at start (not (at-robby ?rob ?from))) ; robot leaves the starting location at start
    ;        (at end (at-robby ?rob ?to)) ; robot arrives at the destination at end
    ;    )
    ;)    
)