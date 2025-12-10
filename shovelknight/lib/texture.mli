(** Textures et dessin des entités *)

type ('a, 'b) sprite
(** Le type va stocker les textures avec comme clé de type ['a] et valeur un rectangle, qui est celui du sprite dans le fichier *)

type 'a sprites
(** Le type des sprites, avec le fichier ainsi que la table des sprites associée*)

val init_rect_with_idx : float -> float -> Raylib.Rectangle.t
(** [init_rect_wth_idx w h] va initialiser un rectangle, pour les sprites dont la feuille contient des sprites de taille uniforme*)

val block_skin_to_string : Types.block_skin -> string
(** [block_skin_to_string bs] renvoie la chaine associée au skin du bloc *)

val get_texture : 'a sprites -> Raylib.Texture.t
(** [get_texture sp] va renvoyer la texture dans [sp]*)

val draw_block : Types.block -> float -> float -> Core.Config.t -> unit
(** [draw_block b i j cfg] va dessiner un bloc situé à [i] [j] dans le fichier *)

val draw_enemy : Types.game_entity -> float -> float -> Types.game_state -> Core.Config.t -> unit
(** [draw_enemy e x y gs cfg] va dessiner l'ennemi [e] qui est situé à [x] [y]*)

val draw_player : 
Types.game_entity ->
  float ->
  float ->
  float ->
  Types.hitbox ->
  Core.Config.t ->
  unit
(** [draw_player p px py hbx cfg] va dessiner le joueur sur l'interface *)

val draw_object :
  Types.game_entity -> float -> float -> Core.Config.t -> unit
(** [draw_object obj ox oy cfg] dessine l'objet sur l'interface *)

val draw_moving_platform : 
  Types.game_entity -> float -> float -> Core.Config.t -> unit
(** [draw_moving_platform p px py cfg] dessine la plateforme mobile sur l'interface *)

val draw_background : Types.level_name -> Core.Config.t -> unit
(** [draw_background level cfg] dessine le fond du niveau [level] sur l'interface *)
