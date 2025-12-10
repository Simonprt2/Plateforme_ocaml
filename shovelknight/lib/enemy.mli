(** Ennemis du jeu *)


(** [initialize_enemy skin at mv h mh pos hw hh] crée un nouvel ennemi avec son skin, type d'attaque, type de mouvement
    pv, pv max, hauteur de l'hitbox ainsi que la longueur *)
val initialize_enemy :
  Types.enemy_skin ->
  Types.attack_type ->
  Types.enemy_movement -> int -> int -> Types.position -> float -> float -> Types.game_entity

(** [create_beeto x y] crée un ennemi Beeto *)
val create_beeto : float -> float -> Types.game_entity

(** [create_blorb x y] crée un ennemi Blorb*)
val create_blorb : float -> float -> Types.game_entity

(** [create_boneclang x y] crée un ennemi Boneclang*)
val create_boneclang : float -> float -> Types.game_entity

(** [create_dozedrake x y] crée un ennemi Dozedrake*)
val create_dozedrake : float -> float -> Types.game_entity

(** [create_firedrake x y] crée un ennemi Firedrake *)
val create_firedrake : float -> float -> Types.game_entity

(** [create_goldarmor x y] crée un ennemi Goldarmor*)
val create_goldarmor : float -> float -> Types.game_entity

(** [create_hoppicles x y] crée un ennemi Hoppicles *)
val create_hoppicles : float -> float -> Types.game_entity

(** [create_moller x y] crée un ennemi Moller *)
val create_moller : float -> float -> Types.game_entity

(** [spawn_enemy e map x] initialise le y pour un ennemi donné sur la map *)
val spawn_enemy :
  Types.game_entity -> Types.block array array -> float -> Types.game_entity

(** [update_enemy_position e dt map p_pos] met à jour la position de l'ennemi en fonction de son mouvement/position du joueur *)
val update_enemy_position :
  Types.game_entity ->
  float -> Types.map -> Types.position -> Types.game_entity

(** [attack_enemy e p] fait attaquer l'ennemi e au joueur p, et renvoie le nouveau p *)
val attack_enemy : Types.game_entity -> Types.game_entity -> Types.game_entity

(** [enemy_of_string s] renvoie le skin associé au string *)
val enemy_of_string : string -> Types.enemy_skin

(** [string_of_enemy skin] renvoie le string associé au skin ennemi *)
val string_of_enemy : Types.enemy_skin -> string

(** [despawn_enemies gs] fait despawn les ennemis morts, et également en faisant tomber des objets *)
val despawn_enemies : 
  Types.game_state ->
  Types.game_entity list * Types.game_entity list

(** [damage_player gs dt] fait infliger des dégâts au joueur par tous les ennemis à la ronde *)
val damage_player : Types.game_state -> float -> Types.game_state

(** [get_cooldown e] donne le cooldown pour la prochaine attaque d'un ennemi *)
val get_cooldown : Types.game_entity -> float

(** [closest_enemy p es] donne l'ennemi le plus proche du joueur *)
val closest_enemy : Types.game_entity -> Types.game_entity list -> Types.game_entity

(** [update_enemy_state p e ] met à jour l'état de l'ennemi *)
val update_enemy_state : Types.game_entity -> Types.game_entity -> Types.game_entity

(** [is_enemy_visible e cam cfg] détermine si l'ennemi est présent sur l'interface (dans le champ de la caméra)*)
val is_enemy_visible : Types.game_entity -> Types.camera -> Core.Config.t -> bool

(** [is_boss_dead gs] détermine si le boss du game_state est mort *)
val is_boss_dead : Types.game_state -> bool
