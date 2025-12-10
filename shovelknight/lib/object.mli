(** Objets du jeu *)

val create_object :
?state:Types.entity_state ->
  ?vx:float ->
  ?vy:float ->
  Types.object_type ->
  float ->
  float ->
  Types.game_entity
(** [create_object es vx vy obj px py] retourne l'objet spécifié *)

val check_object_collision : Types.game_entity -> Types.game_entity -> bool
(** [check_object_collision obj p] teste si l'objet est en collision avec un joueur *)

val apply_object_effect :
  Types.game_state -> Types.game_entity -> Types.game_state
(** [apply_object_effect gs obj] applique sur le joueur l'effet de l'objet *)

val object_of_string : string -> Types.object_type
(** [object_of_string s] renvoie l'objet spécifié par [s]*)

val drop_objects : Types.game_state -> Types.game_entity -> Types.game_entity list
(** [drop_objects gs e] fait tomber des objets selon l'ennemi en question *)

val update_objects : Types.game_state -> Types.game_state
(** [update_objects gs] met à jour tous les objets de l'état du jeu *)

val cast_projectile : Types.game_state -> Types.game_state
(** [cast_projectile gs] ajoute un objet, qui est un projectile *)