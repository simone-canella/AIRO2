(define (problem warehouse_problem)
    (:domain warehouse_domain)
    (:objects
        mover1 mover2 - mover
        loader1 - loader
        crate1 crate2 crate3 crate4 - crate
        initialPosition1 initialPosition2 initialPosition3 initialPosition4 loadingBay - location
        A B - group
    )

    (:init
        ;Initialize distance between object
        (= (loading_time loader1) 0)
        (= (travel_time mover1) 0)
        (= (travel_time mover2) 0)

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
        (in-group crate1 A) ; crate1 is not in any group
        (= (weight crate1) 70)
        (= (doublecarry crate1) 100) ;it's a heavy crate, so it requires double carry
        (not (inTransit crate1)) ; crate1 is not in transit


        ;Crate2 initial configuration
        (at crate2 initialPosition2)
        (in-group crate2 A)
        (= (weight crate2) 80)
        (= (doublecarry crate2) 100) ;it's a light crate, so double carry is faster (smaller weight)
        (fragile crate2) ; crate2 is fragile
        (not (inTransit crate2)) ; crate2 is not in transit

        ;Crate3 initial configuration
        (at crate3 initialPosition3)
        (in-group crate3 B)
        (= (weight crate3) 20)
        (= (doublecarry crate3) 150) ;it's a light crate, so double carry is faster (smaller weight)

        ;Crate4 initial configuration
        (at crate4 initialPosition4)
        (in-group crate4 B)
        (= (weight crate4) 30)
        (= (doublecarry crate4) 150) ;it's a light crate, so double carry is faster (smaller weight)



        ;Group A initial configuration
        (group-active A) ; group A is active
        (= (size A) 2) ; group A has 2 crates
        (= (arrived A) 0) ; no crates have arrived yet

        ;Group B initial configuration
        (= (size B) 2)
        (= (arrived B) 0) ; no crates have arrived yet
        (not (group-active B)) ; B is not active


        (group-next A B) ; group B is next in line

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
        (pickedFrom crate4 initialPosition4)
    )
)


    (:metric minimize (total-time))
    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)
