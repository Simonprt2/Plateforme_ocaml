(**
  module [Config]

  Ce module contient la structure d'une configuration, qui stocke les constantes du jeu
*)
module Config :
  sig
  type t = {
    screen_height : int;
    screen_width : int;
    rows : int;
    cols : int;
    block_height : float;
    block_width : float;
  }
    val initialize : int -> int -> t
    (** [initialize w h] crée une nouvelle configuration, avec la longueur et la hauteur de l'écran en paramètres *)

    val print : t -> unit
    (** [print c] affiche la configuration *)
  end
  
(**
    module [Collision]

    Ce module gère les collisions en général
    
    *)
module Collision :
  sig
  (** [rectangles_collide p1 (w1,h1) p2 (w2,h2)] teste si les deux rectangles en paramètre sont en collision *)
    val rectangles_collide :
      Types.position ->
      float * float -> Types.position -> float * float -> bool

  (** [get_colliding_enemies gs] retourne les ennemis qui sont en collision avec le joueur *)
    val get_colliding_enemies : Types.game_state -> Types.game_entity list
  end

(** module [Hitbox]*)
module Hitbox : sig 
  (** [make_rectangular h w] retourne une hitbox avec la hauteur et la largeur du rectangle en paramètres *)
  val make_rectangular : float -> float -> Types.hitbox 
end

(** module [Map]*)
module Map : sig
  val string_of_block : Types.block -> string
  (** [string_of_block b]*)

  val print_map : Types.block array array -> unit
  (** [print_map map] affiche la map *)

  val find_ground_y :
    Types.block array array -> int -> int option
  (** [find_ground_y map x] trouve le premier y qui est sur le sol, à la colonne x*)
end

(** module [Camera] pour l'intégration de la caméra dans le jeu *)
module Camera : sig
  (** [initialize_camera m c] crée une nouvelle caméra à partir de la config ainsi que de la map *)
  val initialize_camera :
    Types.block array array -> Config.t -> Types.camera
end