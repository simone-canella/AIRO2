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
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

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
        (carryngCrate ?rob - mover ?obj - crate) ;mover holds a crate

        (freeLoader ?rob - loader) ;indicates that loader can load crate
        (loadingCrate ?rob -loader ?obj - crate) ;indicates that loader loads crate 

        (at ?obj - crate ?loc - location) ;where is the crate
        (carried ?obj - crate) ;crate isn't picked up

        ;TODO
        ;(reserved ?obj -crate ?rob - mover) ;a crate is reserved and only the respective mover can pick up it
        ;(linkMover ?rob1 - mover ?rob2 - mover) ;link two mover for transport heavy crate
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
        :parameters (?rob - mover ?from - location ?to - location)
        :precondition (and 
            (at-robby ?rob ?from)
            (freeMover ?rob)
        )
        :effect (and 
            (not (at-robby ?rob ?from))
            (at-robby ?rob ?to)
        )
    )

    ;@Precondition: robot holding carry, carry is holded
    ;@Effect: robot at the end-ocation
    (:action moveLight
        :parameters (?obj - crate?rob - mover ?from - location ?to - location)
        :precondition (and 
            (at-robby ?rob ?from)
            (not (freeMover ?rob))
            (carried ?obj)
            (carryngCrate ?rob ?obj)
        )
        :effect (and 
            (not (at-robby ?rob ?from))
            (at-robby ?rob ?to)
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
    (:action putDown
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