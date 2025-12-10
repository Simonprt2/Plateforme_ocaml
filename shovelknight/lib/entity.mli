(** Entités en général dans le jeu *)

val get_hitbox_dims : Types.hitbox -> float * float
(** [get_hitbox_dims hbx] retourne la longueur et la hauteur de la hitbox *)

val get_bounds : Types.game_entity -> float * float * float * float
(** [get_bounds e] retourne la position x y, ainsi que la longueur et hauteur par rapport à celle-ci *)

val get_current_health : Types.game_entity -> int
(** [get_current_health e] retourne la vie actuelle de l'entité *)

val get_max_health : Types.game_entity -> int
(** [get_max_health e] retourne la vie max de l'entité *)

val print_entities : Types.game_entity list -> unit
(** [print_entity el] affiche sur le terminal la liste des entités *)

val print_entity : Types.game_entity -> unit
(** [print_entity e] affiche sur le terminal l'entité *)

val get_attack_time : Types.game_entity -> float
(** [get_attack_time e] retourne le cooldown restant pour la prochaine attaque *)

val update_attack_time : Types.game_entity -> float -> Types.game_entity
(** [update_attack_time e at] change son temps de recharge en [dt]*)

val is_dead : Types.game_entity -> bool
(** [is_dead e] indique si l'entité est morte *)

val elapse_state : Types.game_entity -> Types.game_entity
(** [elapse_state e] va mettre à jour l'état de l'entité *)

val is_moving : Types.game_entity -> bool
(** [is_moving e] indique si l'entité est en plein mouvement *)

val get_position : Types.game_entity -> float * float
(** [get_position e] retourne la position de l'entité *)

val is_boss : Types.game_entity -> Types.game_state -> bool
(** [is_boss e gs] teste si [es] dans l'état du jeu [gs] *)

val update_moving_platform : Types.game_entity -> float -> Types.game_entity
(** [update_moving_platform e dt] va mettre à jour le mouvement de la plateforme mobile *)

val get_platform_movement : Types.game_entity -> float * float
(** [get_platform_movement e] retourne le mouvement de la plateforme mobile *)

val check_entity_collision : Types.game_entity -> Types.game_entity -> bool
(** [check_entity_collision e1 e2] vérifie si il y a collision entre les deux entités *)

val check_collision_with_entities : Types.game_entity -> Types.game_entity list -> bool
(** [check_collision_with_entities e el] vérifie si il y a collision entre [e] et tous les ennemis dans [el]*)