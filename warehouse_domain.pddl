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
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality :disjunctive-preconditions :time)

    (:types
        mover loader crate location
    )

    ; un-comment following line if constants are needed
    (:constants
        conveyorBelt - location
    )

    ;-------
    ; PREDICATE
    ;-------
    (:predicates
        (at-robby ?rob - mover ?loc - location) ;where is the mover
        (freeMover ?rob - mover) ;mover doesn't take crate
        (carryingCrate ?rob - mover ?obj - crate) ;mover holds a crate -> specify who is the holder of a crate
        (linked ?rob - mover);identify if mover is linked 
        (linkedWith ?rob1 - mover ?rob2 - mover) ;identify with which mover is linked
        (moving ?rob - mover ?from - location ?to - location) ;indicates that mover is moving from one location to another
        (to_load ?obj - crate) ;indicates that crate is to load
        (freeLoader ?rob - loader) ;loader is free to carry
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
        (travel_time ?m - mover) ;time needed to move from one location to another
        (loading_time ?rob - loader) ;time needed to load a crate
)

    ;-------
    ; ACTION
    ;-------

    ;@Precondition: robot at start-location, robot doesn't holding carry
    ;@Effect: robot at end-location
    ; (:action moveFree
    ;     :parameters (?rob1 - mover ?rob2 - mover ?from - location ?to - location)
    ;     :precondition (and
    ;         (at-robby ?rob1 ?from)
    ;         (at-robby ?rob2 ?from)
    ;         (freeMover ?rob1)
    ;         (freeMover ?rob2)

    ;         (linked ?rob1)
    ;         (linked ?rob2)

    ;         (linkedWith ?rob1 ?rob2)
    ;         (linkedWith ?rob2 ?rob1)
    ;     )
    ;     :effect (and
    ;         (not (at-robby ?rob1 ?from))
    ;         (not (at-robby ?rob2 ?from))
    ;         (at-robby ?rob1 ?to)
    ;         (at-robby ?rob2 ?to)
    ;     )
    ; )

    ; ;@Precondition: robot holding crate, carry is holded
    ; ;@Effect: robot at the end-ocation
    ; (:action moveLight
    ;     :parameters (?obj - crate?rob - mover ?from - location ?to - location)
    ;     :precondition (and
    ;         (at-robby ?rob ?from)
    ;         (not (freeMover ?rob))
    ;         (carried ?obj)
    ;         (carryingCrate ?rob ?obj)
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
            (carryingCrate ?rob1 ?obj)
            (carryingCrate ?rob2 ?obj)

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
    ; (:action pickUp
    ;     :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
    ;     :precondition (and
    ;         (at ?obj ?loc)
    ;         (at-robby ?rob1 ?loc)
    ;         (at-robby ?rob2 ?loc)

    ;         (freeMover ?rob1)
    ;         (freeMover ?rob2)

    ;         (not (carried ?obj))

    ;         (not (= ?rob1 ?rob2)) ; robots are different 

    ;         ;WEIGHT CHECK: 
    ;         (or
    ;             (and 
    ;                 (>= (weight ?obj) 50)
    ;                 (linkedWith ?rob1 ?rob2)
    ;             ) ;if weight >= 50, must have two movers linkedWith
                
    ;             (and 
    ;                 (< (weight ?obj) 50) 
    ;                 (or (linkedWith ?rob1 ?rob2) (= ?rob1 ?rob2)) ;robots should be linkedWith (if they are different) or be the same robot 
    ;             ) ; if light crate, can be moved by one or two movers
    ;         )
    ;     )
    ;     :effect (and
    ;         (carried ?obj)
    ;         (carryingCrate ?rob1 ?obj)
    ;         (carryingCrate ?rob2 ?obj)

    ;         (not (freeMover ?rob1))
    ;         (not (freeMover ?rob2))
    ;     )
    ; )

    ;@Precondition: robot and carry at same location, robot doesn't holding carry, carry isn't holded
    ;@Effect: robot take carry

    (:action pickUpLight
    :parameters (?rob - mover ?obj - crate ?loc - location)
    :precondition (and
        (at ?obj ?loc)
        (at-robby ?rob ?loc)
        (freeMover ?rob)
        (< (weight ?obj) 50)
    )
    :effect (and
        (carryingCrate ?rob ?obj)
        (not (freeMover ?rob))
    )
    )

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
    )
    :effect (and
        (carried ?obj)
        (carryingCrate ?rob1 ?obj)
        (carryingCrate ?rob2 ?obj)
        (not (freeMover ?rob1))
        (not (freeMover ?rob2))
        (linkedWith ?rob1 ?rob2)
        (linkedWith ?rob2 ?rob1)
    )
    )




    ; (:action putDown
    ;     :parameters (?rob1 - mover ?rob2 - mover ?obj - crate ?loc - location)
    ;     :precondition (and 
    ;         (carryingCrate ?rob1 ?obj)
    ;         (carryingCrate ?rob2 ?obj)
    ;         (carried ?obj)

    ;         (at-robby ?rob1 ?loc)
    ;         (at-robby ?rob2 ?loc)

    ;         ;WEIGHT CHECK: 
    ;         (or
    ;             (and 
    ;                 (>= (weight ?obj) 50)
    ;                 (linkedWith ?rob1 ?rob2)
    ;             ) ;if weight >= 50, must have two movers linkedWith
                
    ;             (and 
    ;                 (< (weight ?obj) 50) 
    ;                 (or (linkedWith ?rob1 ?rob2) (= ?rob1 ?rob2)) ;robots should be linkedWith (if they are different) or be the same robot 
    ;             ) ; if light crate, can be moved by one or two movers
    ;         )
    ;     )
    ;     :effect (and 
    ;         (not (carryingCrate ?rob1 ?obj))
    ;         (not (carryingCrate ?rob2 ?obj))
    ;         (not (carried ?obj))

    ;         (freeMover ?rob1)
    ;         (freeMover ?rob2)

    ;         (at ?obj ?loc)

    ;         ;OPTIONAL UNLINK ACTION
    ;         ; (when (linkedWith ?rob1 ?rob2) 
    ;         ;     (not (linkedWith ?rob1 ?rob2))
    ;         ; )
    ;     )
    ; )
    




    ;@Precondition: robot take carry, robot in a specific location
    ;@Effect: robot and carry at same location, robot doesn't holding carry, carry isn't holded
    (:action putDownLight
        :parameters (?obj - crate ?rob - mover ?loc - location)
        :precondition (and
            (at-robby ?rob ?loc)
            (carried ?obj)
            (not (freeMover ?rob))
        )
        :effect (and
            (at ?obj ?loc)
            (not (carried ?obj))
            (not (carryingCrate ?rob ?obj))
            (freeMover ?rob)
        )
    )

    ;@Precondition: robot1 and robot2 at same location, robots don't holding carry, robots are not linkedWith
    ;@Effect: robots link to eachother
    ; (:action linkMovers
    ;     :parameters (?rob1 - mover ?rob2 - mover ?loc - location)
    ;     :precondition (and
    ;         (at-robby ?rob1 ?loc)
    ;         (at-robby ?rob2 ?loc)

    ;         (freeMover ?rob1)
    ;         (freeMover ?rob2)

    ;         (not (linked ?rob1))
    ;         (not (linked ?rob2))
    ;     )
    ;     :effect (and
    ;         (linkedWith ?rob1 ?rob2)
    ;         (linkedWith ?rob2 ?rob1)

    ;         (linked ?rob1)
    ;         (linked ?rob2)
    ;     )
    ; )

    ;@Precondition: robot1 and robot2 at same location, robots don't holding carry
    ;@Effect: robots unlink to eachother
    ; (:action unlinkMover
    ;     :parameters (?rob1 - mover ?rob2 - mover ?loc - location)
    ;     :precondition (and
    ;         (linkedWith ?rob1 ?rob2)
    ;         (linkedWith ?rob2 ?rob1)
    ;         (linked ?rob1)
    ;         (linked ?rob2)

    ;         (at-robby ?rob1 ?loc)
    ;         (at-robby ?rob2 ?loc)

    ;         (freeMover ?rob1)
    ;         (freeMover ?rob2)
    ;     )
    ;     :effect (and
    ;         (not (linkedWith ?rob1 ?rob2))
    ;         (not (linkedWith ?rob2 ?rob1))

    ;         (not (linked ?rob1))
    ;         (not (linked ?rob2))
    ;     )
    ; )

    ;-------
    ; PROCESSES
    ;-------

    (:action start_move
        :parameters (?rob - mover ?from - location ?to - location)
        :precondition (and
            (at-robby ?rob ?from)
            (freeMover ?rob))                                           ;;INIZIO MOVIMENTO
        :effect (and 
            (moving ?rob ?from ?to) 
            (not(at-robby ?rob ?from))
            (assign (travel_time ?rob) 0))
    )
    

    (:process moving_process
        :parameters (?rob - mover ?from - location ?to - location)
        :precondition (moving ?rob ?from ?to)                           ;;MOVIMENTO IN CORSO
        :effect (increase (travel_time ?rob) (* #t 1))
    )

    (:event end_move
        :parameters (?rob - mover ?from - location ?to - location)
        :precondition (and
            (moving ?rob ?from ?to)
            (>= (travel_time ?rob) (/(distance ?from ?to) 10))) ;;10 is the speed of the mover
        :effect (and
            (not (moving ?rob ?from ?to))
            (at-robby ?rob ?to)                                         ;;FINE DEL MOVIMENTO
            (freeMover ?rob)
            (assign (travel_time ?rob) 0) ;;reset travel time after moving
            (not (at-robby ?rob ?from))) ;;robot is not at the start location anymore
    )

    (:action start_carrying_light
        :parameters (?rob - mover ?obj - crate ?from - location ?to - location)
        :precondition (and 
            (not(freeMover ?rob)) ;mover is carrying a crate
            (at ?obj ?from)
            (at-robby ?rob ?from)
            (< (weight ?obj) 50))
        :effect (and
            (not (at ?obj ?from))
            (carryingCrate ?rob ?obj))
    )

    (:process carrying_light
        :parameters (?rob - mover ?obj - crate ?from - location ?to - location)
        :precondition (and 
            (carryingCrate ?rob ?obj)
        )
        :effect (and
            (increase (travel_time ?rob) (* #t 1))
        )
    )

    (:event end_carrying_light
        :parameters (?rob - mover ?obj - crate ?from - location ?to - location)
        :precondition (and
            (carryingCrate ?rob ?obj)
            (>= (travel_time ?rob) (/(*(weight ?obj)(distance ?from ?to)) 100))) ;;time needed to carry a light crate is proportional to its weight and distance
        :effect (and
            (not (carryingCrate ?rob ?obj))
            (at ?obj ?to) ;;crate is at the destination after carrying
            (carried ?obj) ;;crate is carried
            (at-robby ?rob ?to) ;;robot is at the destination after carrying
        )
    )


    (:action start_loading
        :parameters (?rob - loader ?obj - crate ?loc - location)
        :precondition (and 
            (to_load ?obj)
            (at ?obj ?loc)
            (at-robby ?rob ?loc)
            (freeLoader ?rob) ;loader is free to load
            )
        :effect (and
            (loadingCrate ?rob ?obj) 
            (not (to_load ?obj)) 
            (not (at ?obj ?loc)) 
            (not (freeLoader ?rob)) 
        )
    )

    (:process loading_process
        :parameters (?rob - loader ?obj - crate)
        :precondition (loadingCrate ?rob ?obj)                           ;;LOADING IN CORSO
        :effect (increase (loading_time ?rob) (* #t 1)) ;;4 is the time needed to load a crate
    )

    (:event end_loading
        :parameters (?rob - loader ?obj - crate)
        :precondition (and
            (loadingCrate ?rob ?obj)
            (>= (loading_time ?rob) 4)) ;;4 is the time needed to load a crate
        :effect (and
            (not (loadingCrate ?rob ?obj)) 
            (freeLoader ?rob) 
            (at ?obj conveyorBelt) ;;crate is at the conveyor belt after loading
            (assign (loading_time ?rob) 0) ;;reset travel time after loading
        )
    )


)