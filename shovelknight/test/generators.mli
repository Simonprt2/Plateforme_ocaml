(** Générateurs pour les tests unitaires *)

val gen_map : Shovelknight.Types.block array array
(** [gen_map] génère une map 100*100 avec le sol à y=98 *)

val map5 :
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f) ->
  'a QCheck.Gen.t ->
  'b QCheck.Gen.t ->
  'c QCheck.Gen.t -> 'd QCheck.Gen.t -> 'e QCheck.Gen.t -> 'f QCheck.Gen.t
(** [map5 f a b c d e] est l'équivalent de QCheck.map avec 5 paramètres *)

val gen_float : float QCheck.Gen.t
(** [gen_float] génère un flottant *)

val gen_position : Shovelknight.Types.position QCheck.Gen.t
(** [gen_position] génère une position *)

val gen_velocity : Shovelknight.Types.velocity QCheck.Gen.t
(** [gen_velocity] génère une vélocité*)

val gen_state : (Shovelknight.Types.entity_state * int) QCheck.Gen.t
(** [gen_state] génère un état d'une entité*)

val gen_rect_hitbox : Shovelknight.Types.hitbox QCheck.Gen.t
(** [gen_rect_hitbox] génère une hitbox rectangulaire*)

val gen_enemy_skin : Shovelknight.Types.enemy_skin QCheck.Gen.t
(** [gen_enemy_skin] génère un skin d'ennemi*)

val gen_attack_type : Shovelknight.Types.attack_type QCheck.Gen.t
(** [gen_attacj_type] génère un type d'attaque*)

val gen_enemy_movement : Shovelknight.Types.enemy_movement QCheck.Gen.t
(** [gen_enemy_movement] génère un mouvement ennemi*)

val gen_enemy_entity : Shovelknight.Types.game_entity QCheck.Gen.t
(** [gen_enemy_entity] génère un ennemi*)

val gen_player_entity : Shovelknight.Types.game_entity QCheck.Gen.t
(** [gen_player_entity] génère un joueur *)

val gen_game_state : Shovelknight.Types.game_state QCheck.Gen.t
(** [gen_game_state] génère un état de jeu *)
