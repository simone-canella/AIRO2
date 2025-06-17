(define (problem warehouse_problem_4)
    (:domain warehouse_domain_4)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 crate3 crate4 crate5 crate6 - crate
        initialPosition1 initialPosition2 initialPosition3 initialPosition4 initialPosition5 initialPosition6 loadingBay - location
        A B nogroup - group
    )

    (:init
        ;Initialize distance between object
        (= (loadingTime loader1) 0)
        (= (travelTime mover1) 0)
        (= (travelTime mover2) 0)

        (= (distance initialPosition1 loadingBay) 20)
        (= (distance initialPosition2 loadingBay) 20)
        (= (distance initialPosition3 loadingBay) 10)
        (= (distance initialPosition4 loadingBay) 20)
        (= (distance initialPosition5 loadingBay) 30)
        (= (distance initialPosition6 loadingBay) 10)

        (= (distance loadingBay initialPosition1) 20)
        (= (distance loadingBay initialPosition2) 20)
        (= (distance loadingBay initialPosition3) 10)
        (= (distance loadingBay initialPosition4) 20)
        (= (distance loadingBay initialPosition5) 30)
        (= (distance loadingBay initialPosition6) 10)

        (at-loader loader1 loadingBay) ; loader1 is at loadingBay
        (freeLoader loader1) ; loader1 is free to carry

        ;Crate1 initial configuration
        (at crate1 initialPosition1)
        (inGroup crate1 A) ; crate1 is not in any group
        (= (weight crate1) 30)
        (= (doubleCarry crate1) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate1)) ; crate1 is not in transit


        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (inGroup crate2 A)
        (= (weight crate2) 20)
        (= (doubleCarry crate2) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate2) ; crate2 is fragile
        (not (inTransit crate2)) ; crate2 is not in transit

        ;Crate3 initial configuration
        (at crate3 initialPosition3)
        (inGroup crate3 B)
        (= (weight crate3) 30)
        (fragile crate3) ; crate3 is fragile
        (= (doubleCarry crate3) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate3)) ; crate3 is not in transit

        ;Crate4 initial configuration
        (at crate4 initialPosition4)
        (inGroup crate4 B)
        (= (weight crate4) 20)
        (fragile crate4) ; crate4 is fragile
        (= (doubleCarry crate4) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate4)) ; crate4 is not in transit


        ;Crate5 initial configuration
        (at crate5 initialPosition5)
        (inGroup crate5 B) ; crate5 is not in any group
        (= (weight crate5) 30)
        (= (doubleCarry crate5) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate5) ; crate5 is fragile
        (not (inTransit crate5)) ; crate5 is not in transit

        ;Crate6 initial configuration
        (at crate6 initialPosition6)
        (inGroup crate6 nogroup) ; crate6 is not in any group
        (= (weight crate6) 20)
        (= (doubleCarry crate6) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate6)) ; crate6 is not in transit



        ;Group A initial configuration
        (groupActive A) ; group A is active
        (= (size A) 2) ; group A has 2 crates
        (= (arrived A) 0) ; no crates have arrived yet

        ;Group nogroup initial configuration
        (= (size nogroup) 1)
        (= (arrived nogroup) 0) ; no crates have arrived yet
        (not (groupActive nogroup)) ; B is not active

        ;Group B initial configuration
        (not (groupActive B)) ; group B is not active
        (= (size B) 3) ; group B has 3 crates
        (= (arrived B) 0) ; no crates have arrived yet


        (groupNext A B) ; group B is next in line
        (groupNext B nogroup) ; nogroup is next in line after B

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
        (onBelt crate5)
        (onBelt crate6)
    )
)


    (:metric minimize (total-time))

)
