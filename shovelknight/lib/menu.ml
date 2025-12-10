open Raylib

type menu_choice = 
  | StartLevel1 
  | StartLevel2
  | ContinueMenu
  | ShowLevelSelection
  | QuitGame
  | ReturnToMainMenu 

let init_menu () = 
  let screen_width = get_screen_width () in
  let screen_height = get_screen_height () in
  (* Rectangle du bouton Jouer *)
  Rectangle.create 
    ((float_of_int screen_width) /. 2. -. 100.) 
    ((float_of_int screen_height) /. 2.) 
    200. 50.

let init_level_selection () =
  let screen_width = get_screen_width () in
  let screen_height = get_screen_height () in
  let level1_button = Rectangle.create 
    ((float_of_int screen_width) /. 2. -. 100.) 
    ((float_of_int screen_height) /. 2.) 
    200. 50. in
  let level2_button = Rectangle.create 
    ((float_of_int screen_width) /. 2. -. 100.) 
    ((float_of_int screen_height) /. 2. +. 70.) 
    200. 50. in
  (level1_button, level2_button)

let draw_menu play_button_rect =
  begin_drawing ();
  clear_background Color.black;

  (* Logo texte simple à remplacer avec le png du logo*)
  let title = "SHOVEL KNIGHT" in
  let title_width = measure_text title 60 in
  draw_text title 
    ((get_screen_width () - title_width) / 2)  (* Centré horizontalement *)
    100  (* Position verticale *)
    60 
    Color.gold;

  (* Bouton Jouer *)
  let button_color = 
    if check_collision_point_rec (get_mouse_position ()) play_button_rect then
      Color.gray
    else 
      Color.darkgray
  in

  draw_rectangle_rec play_button_rect button_color;
  draw_rectangle_lines_ex play_button_rect 2. Color.white;

  (* Texte du bouton *)
  draw_text "JOUER" 
    (int_of_float (Rectangle.x play_button_rect +. 70.)) 
    (int_of_float (Rectangle.y play_button_rect +. 15.)) 
    20 
    Color.white;

  end_drawing ()

let draw_level_selection (level1_button, level2_button) =
  begin_drawing ();
  clear_background Color.black;

  let title = "SELECTION DE NIVEAU" in
  let title_width = measure_text title 40 in
  draw_text title 
    ((get_screen_width () - title_width) / 2)
    100
    40
    Color.gold;

  (* Bouton Niveau 1 *)
  let level1_color = 
    if check_collision_point_rec (get_mouse_position ()) level1_button then
      Color.gray
    else 
      Color.darkgray
  in

  draw_rectangle_rec level1_button level1_color;
  draw_rectangle_lines_ex level1_button 2. Color.white;
  draw_text "NIVEAU 1" 
    (int_of_float (Rectangle.x level1_button +. 60.)) 
    (int_of_float (Rectangle.y level1_button +. 15.)) 
    20 
    Color.white;

  (* Bouton Niveau 2 *)
  let level2_color = 
    if check_collision_point_rec (get_mouse_position ()) level2_button then
      Color.gray
    else 
      Color.darkgray
  in

  draw_rectangle_rec level2_button level2_color;
  draw_rectangle_lines_ex level2_button 2. Color.white;
  draw_text "NIVEAU 2" 
    (int_of_float (Rectangle.x level2_button +. 60.)) 
    (int_of_float (Rectangle.y level2_button +. 15.)) 
    20 
    Color.white;

  end_drawing ()

let update_menu play_button_rect =
  if is_key_pressed Key.Enter then ShowLevelSelection
  else if is_mouse_button_pressed MouseButton.Left && 
      check_collision_point_rec (get_mouse_position ()) play_button_rect then
    ShowLevelSelection
  else 
    ContinueMenu

let update_level_selection (level1_button, level2_button) =
  if is_mouse_button_pressed MouseButton.Left then
    if check_collision_point_rec (get_mouse_position ()) level1_button then
      StartLevel1
    else if check_collision_point_rec (get_mouse_position ()) level2_button then
      StartLevel2
    else
      ContinueMenu
  else
    ContinueMenu



(* gestion du menu endgame *)


let init_end_game_menu () =
let screen_width = get_screen_width () in
let screen_height = get_screen_height () in
let return_button = Rectangle.create 
  ((float_of_int screen_width) /. 2. -. 100.) 
  ((float_of_int screen_height) /. 2.) 
  200. 50. in
let quit_button = Rectangle.create 
  ((float_of_int screen_width) /. 2. -. 100.) 
  ((float_of_int screen_height) /. 2. +. 70.) 
  200. 50. in
(return_button, quit_button)

let draw_end_game_menu (return_button, quit_button) =
  begin_drawing ();
  clear_background Color.black;

  let title = "FIN DU NIVEAU" in
  let title_width = measure_text title 60 in
  draw_text title 
    ((get_screen_width () - title_width) / 2)
    100
    60 
    Color.gold;

  (* Bouton Retour au menu *)
  let return_color = 
    if check_collision_point_rec (get_mouse_position ()) return_button then
      Color.gray
    else 
      Color.darkgray
  in

  draw_rectangle_rec return_button return_color;
  draw_rectangle_lines_ex return_button 2. Color.white;
  draw_text "RETOUR AU MENU" 
    (int_of_float (Rectangle.x return_button +. 30.)) 
    (int_of_float (Rectangle.y return_button +. 15.)) 
    20 
    Color.white;

  (* Bouton Quitter *)
  let quit_color = 
    if check_collision_point_rec (get_mouse_position ()) quit_button then
      Color.gray
    else 
      Color.darkgray
  in

  draw_rectangle_rec quit_button quit_color;
  draw_rectangle_lines_ex quit_button 2. Color.white;
  draw_text "QUITTER" 
    (int_of_float (Rectangle.x quit_button +. 60.)) 
    (int_of_float (Rectangle.y quit_button +. 15.)) 
    20 
    Color.white;

  end_drawing ()

let update_end_game_menu (return_button, quit_button) =
  if is_mouse_button_pressed MouseButton.Left then
    if check_collision_point_rec (get_mouse_position ()) return_button then
      ReturnToMainMenu
    else if check_collision_point_rec (get_mouse_position ()) quit_button then
      QuitGame
    else
      ContinueMenu
  else
    ContinueMenu


exception EndLevelTriggered

let end_level_loop () =
  let end_buttons = init_end_game_menu () in
  let should_continue = ref true in
  
  while !should_continue do
    begin_drawing ();
    draw_end_game_menu end_buttons;
    end_drawing ();
    
    match update_end_game_menu end_buttons with
    | ReturnToMainMenu -> should_continue := false
    | QuitGame -> close_window (); exit 0
    | _ -> ()
  done