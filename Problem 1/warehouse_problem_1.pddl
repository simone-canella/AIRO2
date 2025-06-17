(define (problem warehouse_problem_1)
    (:domain warehouse_domain_1)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 crate3 - crate
        initialPosition1 initialPosition2 initialPosition3 loadingBay - location
        A nogroup - group
    )

    (:init
        ;Initialize distance between object
        (= (loadingTime loader1) 0)
        (= (travelTime mover1) 0)
        (= (travelTime mover2) 0)

        (= (distance initialPosition1 loadingBay) 10)
        (= (distance initialPosition2 loadingBay) 20)
        (= (distance initialPosition3 loadingBay) 20)

        (= (distance loadingBay initialPosition1) 10)
        (= (distance loadingBay initialPosition2) 20)
        (= (distance loadingBay initialPosition3) 20)

        (at-loader loader1 loadingBay) ; loader1 is at loadingBay
        (freeLoader loader1) ; loader1 is free to carry

        ;Crate1 initial configuration
        (at crate1 initialPosition1)
        (inGroup crate1 nogroup) ; crate1 is not in any group
        (= (weight crate1) 70)
        (= (doubleCarry crate1) 100) ;it's a heavy crate, so it requires double carry

        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (inGroup crate2 A) ; crate2 is in group A
        (= (weight crate2) 20)
        (= (doubleCarry crate2) 150) ;it's a light crate, so double carry is faster (smaller weight)

        ;Crate3 initial configuration
        (at crate3 initialPosition3)
        (inGroup crate3 A) ; crate3 is in group A
        (= (weight crate3) 20)
        (= (doubleCarry crate3) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate3) ; crate3 is fragile

        ;Group A initial configuration
        (groupActive A) ; group A is active
        (= (size A) 2) ; group A has 2 crates
        (= (arrived A) 0) ; no crates have arrived yet

        (= (size nogroup) 1)
        (= (arrived nogroup) 0) ; no crates have arrived yet
        (not (groupActive nogroup)) ; nogroup is not active


        (groupNext A nogroup) ; group nogroup is next in line

        ;Mover1 initial configuration
        (at-robby mover1 loadingBay)
        (freeMover mover1) ; mover1 is free to carry

        ;Mover2 initial configuration
        (at-robby mover2 loadingBay)
        (freeMover mover2) ; mover2 is free to carry

    )

    (:goal
    (and
    (onBelt crate2)
    (onBelt crate3)
    (onBelt crate1)
))


    (:metric minimize (total-time))
)
