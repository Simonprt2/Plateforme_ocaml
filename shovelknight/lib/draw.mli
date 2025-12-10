(** Draw pour dessiner sur l'interface graphique *)

(** [get_map_offsets c] affiche les offsets de la map grâce à la caméra *)
val get_map_offsets : Types.camera -> int * int * float * float

(** [world_to_screen cam pos cfg ] donne les position écran d'une certaine position, la position étant en coordonnées blocs *)
val world_to_screen :
  Types.camera -> Types.position -> Core.Config.t -> float * float

(** [draw_map cam map cfg ] dessine la map, à partir de la matrice de blocs map *)
val draw_map :
  Types.camera -> Types.block array array -> Core.Config.t -> unit

(** [render_player cam player cfg] dessine le joueur sur l'écran *)
val render_player :
  Types.camera -> Types.game_entity -> Core.Config.t -> unit

(** [draw_camera_info cam cfg] dessine les infos de la caméra sur l'interface *) 
val draw_camera_info : Types.camera -> Core.Config.t -> unit

(** [draw_entity_infos e cfg] dessine les infos de l'entité sur l'interface *)
val draw_entity_infos : Types.game_entity -> Core.Config.t ->  unit

(** [draw_objects cam objs cdg ] dessine les objets sur l'interface *)
val draw_objects :
  Types.camera -> Types.game_entity list -> Core.Config.t -> unit

(** [render gs cfg] dessine le jeu entier sur l'interface  *)
val render : Types.game_state -> Core.Config.t -> unit
