open Types

(** Joueur du jeu *)

val initialize_player : string -> game_entity
(** [initialize_player name] va créer un joueur avec son nom [nom]*)

val update_position : game_entity -> float -> float -> game_entity
(** [update_position p x y] change la position du joueur [p] en [x] [y]*)

val is_on_ladder : game_entity -> block array array -> bool
(** [is_on_ladder p map] détermine si le joueur est sur une échelle *)

val spawn_player : game_entity -> block array array -> float -> game_entity
(** [spawn_player p map x] va mettre à jour la position du joueur [p] en le faisant apparaitre à x=[x]*)

val check_map_collision : game_entity -> block array array -> bool
(** [check_map_collision p map] teste si le joueur est en collision avec la map *)

val check_platform_collision : game_entity -> game_entity list -> bool
(** [check_platform collision p mvs] teste si le joueur est en collision avec les plateformes mobiles [mvs]*)

val update_player_state : game_state -> state -> game_state
(** [update_player_state gs s] met à jour l'état du joueur *)

val string_of_state : state -> string
(** [string_of_state s] renvoie la chaine associé à l'état du joueur *)

val get_player_state : game_entity -> state
(** [get_player_state p] renvoie l'état du joueur *)

val get_player_attack_time : game_entity -> float
(** [get_player_attacj_time p] renvoie le temps de recharge du joueur pour la prochaine attaque *)

val update_player_hitbox : game_state -> float -> float -> game_state
(** [update_player_hitbox gs hh hw] met à jour la hitbox du joueur *)

val update_attack_time : game_state -> float -> game_state
(** [update_attack_time gs dt] met à jour le temps de recharge de l'attaque du joueur *)

val inflict_damage_around : game_state -> game_state
(** [inflict_damage_around gs] inflige des dégats aux ennemis autour du joueur *)

val update_player_attack : game_state -> int -> game_state
(** [update_player_attack] va changer les dégats du joueur *)

val reset_player : game_entity -> block array array -> game_entity
(** [reset_player p map] réinitialise le joueur *)

val interact_with_blocks : game_state -> game_state
(** [interact_with_blocks gs] va interagir le joueur avec les blocs interactifs *)

val get_player_name : game_entity -> string
(** [get_player_name p] renvoie le nom du joueur *)

val move_with_platform : game_entity -> game_entity list -> float -> game_entity
(** [move_with_platform p mps dt] va faire bouger le joueur selon les plateformes mobiles*)

val is_on_ground : game_entity -> block array array -> game_entity list -> bool
(** [is_on_ground p map mps] détermine si le joueur est sur le sol *)
    
