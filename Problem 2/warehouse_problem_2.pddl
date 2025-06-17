(define (problem warehouse_problem_2)
    (:domain warehouse_domain_2)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 crate3 crate4 - crate
        initialPosition1 initialPosition2 initialPosition3 initialPosition4 loadingBay - location
        A B - group
    )

    (:init
        ;Initialize distance between object
        (= (loadingTime loader1) 0)
        (= (travelTime mover1) 0)
        (= (travelTime mover2) 0)

        (= (distance initialPosition1 loadingBay) 10)
        (= (distance initialPosition2 loadingBay) 20)
        (= (distance initialPosition3 loadingBay) 20)
        (= (distance initialPosition4 loadingBay) 10)

        (= (distance loadingBay initialPosition1) 10)
        (= (distance loadingBay initialPosition2) 20)
        (= (distance loadingBay initialPosition3) 20)
        (= (distance loadingBay initialPosition4) 10)

        (at-loader loader1 loadingBay) ; loader1 is at loadingBay
        (freeLoader loader1) ; loader1 is free to carry

        ;Crate1 initial configuration
        (at crate1 initialPosition1)
        (inGroup crate1 A) ; crate1 is not in any group
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
        (inGroup crate3 B)
        (= (weight crate3) 20)
        (= (doubleCarry crate3) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate3)) ; crate3 is not in transit

        ;Crate4 initial configuration
        (at crate4 initialPosition4) 
        (inGroup crate4 B) 
        (= (weight crate4) 30)
        (= (doubleCarry crate4) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate4)) ; crate4 is not in transit



        ;Group A initial configuration
        (groupActive A) ; group A is active
        (= (size A) 2) ; group A has 2 crates
        (= (arrived A) 0) ; no crates have arrived yet

        ;Group B initial configuration
        (= (size B) 2) ; group B has 2 crates
        (= (arrived B) 0) ; no crates have arrived yet
        (not (groupActive B)) ; B is not active


        (groupNext A B) ; group B is next in line

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
        (onBelt crate4)
    )
)


    (:metric minimize (total-time))

)
