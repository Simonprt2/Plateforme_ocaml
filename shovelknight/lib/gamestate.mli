open Types

(** Monade du gamestate pour enchaîner les fonctions de mise à jour *)
module GSMonad : sig
    type 'a t = game_state -> 'a * game_state
  
    val return : 'a -> 'a t
    val bind : 'a t -> ('a -> 'b t) -> 'b t
    val get : game_state t
    val put : game_state -> unit t
    val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
    val apply : (game_state -> game_state) -> unit t
  end

val print_gamestate : game_state -> unit
(** [print_gamestate gs] affiche l'état du jeu dans le terminal *)


val reset_gamestate : game_state -> Core.Config.t -> game_state
(** [reset_gamestate gs cfg] réinitialise l'état du jeu *)
