(define (problem warehouse_problem_05)
    (:domain warehouse_domain_05)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 - crate
        initialPosition1 initialPosition2 loadingBay - location
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
        (= (doubleCarry crate1) 100) ;it's a heavy crate, so it requires double carry

        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (= (weight crate2) 20)
        (= (doubleCarry crate2) 150) ;it's a light crate, so double carry is faster (smaller weight)



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
           (onBelt crate1)
           (onBelt crate2) 
)               
                         
    )

    (:metric minimize (total-time))
    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)