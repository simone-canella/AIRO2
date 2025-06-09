(define (domain warehouse_domain)
  (:requirements :strips :typing :numeric-fluents :equality :time)

  (:types
    mover loader crate location
  )

  (:predicates
    (loading ?l - loader ?c - crate)
    (on_belt ?c - crate)
    (to_load ?c - crate)
    (at ?c - crate ?l - location)
    (at_mover ?m - mover ?l - location)
    (at_loader ?l - loader ?loc - location)
    (free ?m - mover)
    (free_loader ?l - loader)
    (moving ?m - mover ?from - location ?to - location)
  )

  (:functions
    (loading_progress ?c - crate)
    (travel_time ?l - loader)
    (distance ?from - location ?to - location)
  )

  ;; INIZIO MOVIMENTO
  (:action start_move
    :parameters (?m - mover ?from - location ?to - location)
    :precondition (and (at_mover ?m ?from) (free ?m))
    :effect (and
              (moving ?m ?from ?to)
              (not (at_mover ?m ?from))
              (assign (travel_time ?m) 0))
  )

  ;; PROCESSO: AVANZAMENTO DEL MOVIMENTO
  (:process move_process
    :parameters (?m - mover ?from - location ?to - location)
    :precondition (moving ?m ?from ?to)
    :effect (increase (travel_time ?m) (* #t 1))
  )

  ;; EVENTO: MOVIMENTO COMPLETATO
  (:event end_move
    :parameters (?m - mover ?from - location ?to - location)
    :precondition (and
                    (moving ?m ?from ?to)
                    (>= (travel_time ?m) (/ (distance ?from ?to) 10)))
    :effect (and
              (not (moving ?m ?from ?to))
              (at_mover ?m ?to)
              (free ?m)
              (assign (travel_time ?m) 0))
  )

  ;; INIZIO CARICAMENTO
  (:action start_loading
    :parameters (?l - loader ?c - crate ?loc - location)
    :precondition (and 
                    (to_load ?c)
                    (at ?c ?loc)
                    (free_loader ?l))
    :effect (and 
              (loading ?l ?c)
              (not (free_loader ?l)))
  )

  ;; PROCESSO: CARICAMENTO CONTINUO
  (:process loading_crate
    :parameters (?l - loader ?c - crate)
    :precondition (loading ?l ?c)
    :effect (increase (loading_progress ?c) (* #t 1))
  )

  ;; EVENTO: CARICAMENTO COMPLETO
  (:event loading_complete
    :parameters (?l - loader ?c - crate)
    :precondition (and 
                    (loading ?l ?c)
                    (>= (loading_progress ?c) 4))
    :effect (and 
              (on_belt ?c)
              (not (to_load ?c))
              (not (loading ?l ?c))
              (free_loader ?l)
              (assign (loading_progress ?c) 0))
  )
)
