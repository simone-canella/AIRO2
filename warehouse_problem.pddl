(define (problem warehouse_problem)
    (:domain warehouse_domain)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 - crate
        initialPosition1 initialPosition2 loadingBay - location
    )

    (:init
        ;Initialize distance between object
        (= (distance loadingBay initialPosition1) 10)
        (= (distance loadingBay initialPosition2) 20)

        ;Crate1 initial configuration
        (at crate1 initialPosition1)
        (= (weight crate1) 40)

        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (= (weight crate2) 20)

        ;Mover1 initial configuration
        (at-robby mover1 loadingBay)
        ;(= (distance mover1) 0)
        (freeMover mover1)
        (linkedWith mover1 mover1)
        (linked mover1)

        ;Mover2 initial configuration
        (at-robby mover2 loadingBay)
        ;(= (distance mover2) 0)
        (freeMover mover2)
        (linkedWith mover2 mover2)
        (linked mover2)

        ;Initialize constant value
        ;(= (time) 0)
    )

    (:goal
        (and
            (at crate2 conveyorBelt) ; crate2 must be at conveyorBelt
            (at crate1 conveyorBelt) ; crate1 must be at conveyorBelt
        )
    )

    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)