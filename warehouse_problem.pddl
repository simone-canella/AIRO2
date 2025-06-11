(define (problem warehouse_problem)
    (:domain warehouse_domain)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 - crate
        initialPosition1 initialPosition2 - location
    )

    (:init
        ;Initialize distance between object
        (= (loading_time loader1) 0)
        (= (travel_time mover1) 0)
        (= (travel_time mover2) 0)

        (= (distance initialPosition1 loadingBay) 10)
        (= (distance initialPosition2 loadingBay) 20)

        (= (distance loadingBay initialPosition1) 10)
        (= (distance loadingBay initialPosition2) 20)

        (at-loader loader1 loadingBay) ; loader1 is at loadingBay
        (freeLoader loader1) ; loader1 is free to carry

        ;Crate1 initial configuration
        (at crate1 initialPosition1)
        (= (weight crate1) 70)

        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (= (weight crate2) 20)

        ;Mover1 initial configuration
        (at-robby mover1 loadingBay)
        ;(= (distance mover1) 0)
        (freeMover mover1)

        ;Mover2 initial configuration
        (at-robby mover2 loadingBay)
        ;(= (distance mover2) 0)
        (freeMover mover2)

        ;Initialize constant value
        ;(= (time) 0)
    )

    (:goal (and
           (onBelt crate1)) ; crate1 must be at conveyorBelt
           ;;(onBelt crate2)) ; crate2 must be at conveyorBelt                  ;RIGHT NOW ENSHP DOESN'T MANAGE TO GET BOTH CRATES ON THE BELT (TRY WITH ONLY ONE CRATE AND DEBUG ALL STEPS TOWARDS SECOND CRATE)
                         
    )

    (:metric minimize (total-time))
    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)