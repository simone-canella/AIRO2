(define (problem warehouse_problem) (:domain warehouse_domain)
(:objects 
    mover1 mover2 - mover
    loader1 - loader
    crate1 crate2 - crate
    loading_bay conveyor_belt loc1 loc2 - location 
)

(:init
(at_crate crate1 loc1)
(at_crate crate2 loc2)
(heavy crate1)
(light crate2)
(groupA crate2)
(freeMover mover1)
(freeMover mover2)
(freeLoader loader1)
(at_robby mover1 loading_bay)
(at_robby mover2 loading_bay)

(= (distance loading_bay loc1) 10)
(= (distance loading_bay loc2) 20)
(= (loading_duration) 4)
(= (weight crate1) 70)
(= (weight crate2) 20)
)

(:goal (and
(on_belt crate1 conveyor_belt) (on_belt crate2 conveyor_belt)
))


)
