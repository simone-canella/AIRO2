(define (problem warehouse_problem)
  (:domain warehouse_domain)

  (:objects
    l1 l2 loading_bay - location
    loader1 - loader
    mover1 mover2 - mover
    crate1 crate2 - crate
  )

  (:init
    ;; posizioni iniziali
    (at_mover mover1 loading_bay)
    (at_mover mover2 loading_bay)
    (at_loader loader1 loading_bay)
    (at crate1 l1)
    (at crate2 l2)

    ;; casse da caricare
    (to_load crate1)
    (to_load crate2)

    ;; loader libero
    (free mover1)
    (free mover2)   
    (free_loader loader1)

    ;; progressi iniziali
    (= (loading_progress crate1) 0)
    (= (loading_progress crate2) 0)
    (= (travel_time mover1) 0)
    (= (travel_time mover2) 0)

    ;; stato iniziale delle casse
    (= (distance l1 loading_bay) 10)
    (= (distance l2 loading_bay) 20)
    (not (on_belt crate1))
    (not (on_belt crate2))
  )

  (:goal
    (and
      (on_belt crate1)
      (on_belt crate2)
    )
  )
)
