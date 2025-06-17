(define (problem warehouse_problem_3)
    (:domain warehouse_domain_3)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 crate3 crate4 - crate
        initialPosition1 initialPosition2 initialPosition3 initialPosition4 loadingBay - location
        A nogroup - group
    )

    (:init
        ;Initialize distance between object
        (= (loadingTime loader1) 0)
        (= (travelTime mover1) 0)
        (= (travelTime mover2) 0)

        (= (distance initialPosition1 loadingBay) 20)
        (= (distance initialPosition2 loadingBay) 20)
        (= (distance initialPosition3 loadingBay) 30)
        (= (distance initialPosition4 loadingBay) 10)

        (= (distance loadingBay initialPosition1) 20)
        (= (distance loadingBay initialPosition2) 20)
        (= (distance loadingBay initialPosition3) 30)
        (= (distance loadingBay initialPosition4) 10)

        (at-loader loader1 loadingBay) ; loader1 is at loadingBay
        (freeLoader loader1) ; loader1 is free to carry

        ;Crate1 initial configuration
        (at crate1 initialPosition1)
        (inGroup crate1 A)
        (= (weight crate1) 70)
        (= (doubleCarry crate1) 100) ;it's a heavy crate, so it requires double carry
        (not (inTransit crate1)) ; crate1 is not in transit


        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (inGroup crate2 A)
        (= (weight crate2) 80)
        (= (doubleCarry crate2) 100) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate2) ; crate2 is fragile
        (not (inTransit crate2)) ; crate2 is not in transit

        ;Crate3 initial configuration
        (at crate3 initialPosition3)
        (inGroup crate3 A)
        (= (weight crate3) 60)
        (= (doubleCarry crate3) 100) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate3)) ; crate3 is not in transit

        ;Crate4 initial configuration
        (at crate4 initialPosition4)
        (inGroup crate4 nogroup) ; crate4 is not in any group
        (= (weight crate4) 30)
        (= (doubleCarry crate4) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate4)) ; crate4 is not in transit



        ;Group A initial configuration
        (groupActive A) ; group A is active
        (= (size A) 3) ; group A has 2 crates
        (= (arrived A) 0) ; no crates have arrived yet

        ;Group B initial configuration
        (= (size nogroup) 1) 
        (= (arrived nogroup) 0) ; no crates have arrived yet
        (not (groupActive nogroup)) ; B is not active


        (groupNext A nogroup) ; group B is next in line

        ;Mover1 initial configuration
        (at-robby mover1 loadingBay)

        (freeMover mover1)

        ;Mover2 initial configuration
        (at-robby mover2 loadingBay)

        (freeMover mover2)


    )

(:goal
    (and
        (onBelt crate2)
        (onBelt crate3)
        (onBelt crate1)
        (onBelt crate4)
    )
)


    (:metric minimize (total-time))

)
