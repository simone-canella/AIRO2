(define (problem warehouse_problem)
    (:domain warehouse_domain)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 crate3 crate4 crate5 crate6 - crate
        initialPosition1 initialPosition2 initialPosition3 initialPosition4 initialPosition5 initialPosition6 loadingBay - location
        A B nogroup - group
    )

    (:init
        ;Initialize distance between object
        (= (loading_time loader1) 0)
        (= (travel_time mover1) 0)
        (= (travel_time mover2) 0)

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
        (in-group crate1 A) ; crate1 is not in any group
        (= (weight crate1) 30)
        (= (doublecarry crate1) 150) ;it's a heavy crate, so it requires double carry
        (not (inTransit crate1)) ; crate1 is not in transit


        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (in-group crate2 A)
        (= (weight crate2) 20)
        (= (doublecarry crate2) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate2) ; crate2 is fragile
        (not (inTransit crate2)) ; crate2 is not in transit

        ;Crate3 initial configuration
        (at crate3 initialPosition3)
        (in-group crate3 B)
        (= (weight crate3) 30)
        (fragile crate3) ; crate3 is fragile
        (= (doublecarry crate3) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate3)) ; crate3 is not in transit

        ;Crate4 initial configuration
        (at crate4 initialPosition4)
        (in-group crate4 B)
        (= (weight crate4) 20)
        (fragile crate4) ; crate4 is fragile
        (= (doublecarry crate4) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate4)) ; crate4 is not in transit


        ;Crate5 initial configuration
        (at crate5 initialPosition5)
        (in-group crate5 B) ; crate5 is not in any group
        (= (weight crate5) 30)
        (= (doublecarry crate5) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate5) ; crate5 is fragile
        (not (inTransit crate5)) ; crate5 is not in transit

        ;Crate6 initial configuration
        (at crate6 initialPosition6)
        (in-group crate6 nogroup) ; crate6 is not in any group
        (= (weight crate6) 20)
        (= (doublecarry crate6) 150) ;it's a light crate, so double carry is faster (smaller weight)
        (not (inTransit crate6)) ; crate6 is not in transit



        ;Group A initial configuration
        (group-active A) ; group A is active
        (= (size A) 2) ; group A has 2 crates
        (= (arrived A) 0) ; no crates have arrived yet

        ;Group nogroup initial configuration
        (= (size nogroup) 1)
        (= (arrived nogroup) 0) ; no crates have arrived yet
        (not (group-active nogroup)) ; B is not active

        ;Group B initial configuration
        (not (group-active B)) ; group B is not active
        (= (size B) 3) ; group B has 3 crates
        (= (arrived B) 0) ; no crates have arrived yet


        (group-next A B) ; group B is next in line
        (group-next B nogroup) ; nogroup is next in line after B

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
    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)
