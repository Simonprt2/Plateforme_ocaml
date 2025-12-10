type entity
type level

(** Chargement des niveaux depuis un fichier json *)

val create_level : string -> string -> Core.Config.t -> Types.game_state
(** [create_level name path cfg] renvoie le niveau associé au fichier json [path] avec le nom du joueur [name]*)
