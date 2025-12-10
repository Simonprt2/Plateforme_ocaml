open Raylib

type menu_choice = 
  | StartLevel1 
  | StartLevel2
  | ContinueMenu
  | ShowLevelSelection
  | QuitGame
  | ReturnToMainMenu 

val init_menu : unit -> Rectangle.t

val init_level_selection : unit -> Rectangle.t * Rectangle.t

val draw_menu : Rectangle.t -> unit

val draw_level_selection : Rectangle.t * Rectangle.t -> unit

val update_menu : Rectangle.t -> menu_choice

val update_level_selection : Rectangle.t * Rectangle.t -> menu_choice

val init_end_game_menu : unit -> Rectangle.t * Rectangle.t

val draw_end_game_menu : Rectangle.t * Rectangle.t -> unit

val update_end_game_menu : Rectangle.t * Rectangle.t -> menu_choice

exception EndLevelTriggered

val end_level_loop : unit -> unit