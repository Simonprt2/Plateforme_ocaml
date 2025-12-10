(** Etat des entités du jeu *)

val hitbox_of_state : Types.entity_state -> Types.hitbox
(** [hitbox_of_state p] Renvoie la hitbox associée à l'état de l'entité *)

val get_entity_state : Types.state -> Types.entity_state
(** [get_entity_state s] renvoie le nom de l'état de l'entité *)

val initialize_state : Types.entity_state -> Types.state
(** [initialize_state es] initialise le compteur de l'état de l'entité *)

val get_animation_delay : Types.state -> int 
(** [get_animation_delay s] renvoie la durée de l'animation lorsque l'état est enclenché *)

val get_frames_state : Types.game_entity -> int
(** [get_frame_state e] renvoie le nombre de frames causée par l'animation de l'état *)

val get_sprite_index : Types.game_entity -> Types.state
(** [get_sprite_index e] renvoie l'index de la frame lors d'un compteur d'état quelconque *)