open Core.Config
open Types
open Player
open Object
open Enemy
open State
open Gamestate
open Draw

open GSMonad

(* Constantes globales *)
let gravity = 0.02      (* Force de gravité *)
let jump_force = -0.4   (* Force du saut (négative car Y décroît vers le haut) *)
let max_fall_speed = 0.5 (* Limite de vitesse de chute *)

let clamp v min_val max_val =
  max min_val (min v max_val)

let update_game_state gs config =
  (* Si le joueur meurt alors il respawn *)
  if Entity.is_dead gs.player then
    reset_gamestate gs config 
  else
    (* Mise a jour de la caméra *)
    let screen_width = float_of_int config.screen_width in
    let screen_height = float_of_int config.screen_height in
    let bw = config.block_width in
    let bh = config.block_height in 
    let center_x = screen_width /. (2. *. bw) in
    let center_y = screen_height /. (2. *. bh) in 
    let camera_x = gs.player.position.x -. center_x in
    let camera_y = gs.player.position.y -. center_y in

    let max_camera_x = float_of_int (Array.length gs.map.(0)) -. (screen_width /. bw) in
    let max_camera_y = float_of_int (Array.length gs.map) -. (screen_height /. config.block_height) in
    let clamped_cx = clamp camera_x 0.0 max_camera_x in
    let clamped_cy = clamp camera_y 0.0 max_camera_y in

    { gs with camera = { cx = clamped_cx; cy = clamped_cy } }
  

let update_player_movement player map platforms =
  let open Raylib in 
  let speed = 0.1 in
  let climb_speed = 0.08 in
  
  (* Gestion des échelles - prioritaire sur les autres mouvements *)
  if is_on_ladder player map && (is_key_down Key.Up || is_key_down Key.Down) then
    let vy = 
      if is_key_down Key.Up then -.climb_speed
      else if is_key_down Key.Down then climb_speed
      else 0.0
    in
    { vx = 0.0; vy }
  else
    (* Mouvement normal *)
    let vx =
      if is_key_down Key.Right then speed
      else if is_key_down Key.Left then -.speed
      else 0.0
    in
    let vy =
      if is_key_pressed Key.Space && is_on_ground player map platforms then jump_force
      else min (player.velocity.vy +. gravity) max_fall_speed
    in
    { vx; vy }

  let update_player_state_and_damage gs =
    (* Mise a jour de l'état du joueur *)
    let old_entity_state, old_timer = get_player_state gs.player in
    let cur_attack_time = get_player_attack_time gs.player in
    let vy = gs.player.velocity.vy in
    let vx = gs.player.velocity.vx in
  
    let new_entity_state, attack_timer =
      if Raylib.is_key_pressed Raylib.Key.Enter then Attacking, 0.4
      else if (is_on_ladder gs.player gs.map) && (Raylib.is_key_down Raylib.Key.Up || Raylib.is_key_down Raylib.Key.Down) then Climbing, 0.0
      else if old_entity_state = Jumping && vy >= 0.0 then Falling, 0.0
      else if old_entity_state = Jumping then Jumping, 0.0
      else if vy < -0.1 then Jumping, 0.0
      else if vy > 0.1 then Falling, 0.0
      else if vx <> 0. then Running, 0.0
      else if cur_attack_time > 0.0 then Attacking, cur_attack_time -. Raylib.get_frame_time ()
      else Idle, 0.0
    in
  
    (* On teste si le joueur a lancé un projectile *)
    let gs = if Raylib.is_key_pressed Raylib.Key.S then Object.cast_projectile gs else gs in
  
    (* Si changement de state, alors on initialise le compteur à 0 *)
    let new_state =
      if old_entity_state <> new_entity_state then (new_entity_state, 0)
      else (new_entity_state, old_timer)
    in
  
    let updated_gs = update_player_state gs new_state in

    (* Si le joueur est en train d'attaquer alors on met à jour son temps de recharge *)
    let updated_gs = update_attack_time updated_gs attack_timer in
  
    (* Si le joueur attaque alors on inflige des dégats *)
    let final_gs =
      if (get_entity_state new_state) = Attacking && Raylib.is_key_pressed Raylib.Key.Enter then
        inflict_damage_around updated_gs
      else
        updated_gs
    in
  
    (final_gs.player, attack_timer, final_gs)
  
  

let update_player_position player map platforms velocity =
  let pos = player.position in
  let (w, h) = Entity.get_hitbox_dims player.hitbox in

  (* calcul de la nouvelle position brute *)
  let new_x = pos.x +. velocity.vx in
  let new_y = pos.y +. velocity.vy in

  (* clamp horizontal *)
  let max_x = float_of_int (Array.length map.(0)) -. w in
  let clamped_x = clamp new_x 0.0 max_x in

  (* collision murs -> on bloque en x *)
  let test_x_ent = { player with position = { pos with x = clamped_x } } in
  let final_x = if check_map_collision test_x_ent map then pos.x else clamped_x in

  (* on gère le vertical *)
  (* 1) collision sol identique *)
  let max_y = float_of_int (Array.length map) -. h in
  let clamped_y = clamp new_y 0.0 max_y in
  let test_y_ent = { player with position = { x = final_x; y = clamped_y } } in
  let hit_wall = check_map_collision test_y_ent map in

  (* 2) collision plateformes « classique » *)
  let hit_plat_simple =
    velocity.vy > 0.0 && check_platform_collision test_y_ent platforms
  in

  (* 3) détection de crossing : on regarde pour chaque plateforme
     si on est passé du dessus vers le dessous dans ce frame *)
  let landing_y_opt =
    if velocity.vy > 0.0 then
      List.find_map (fun plat ->
        let plat_top = plat.position.y in
        let (pw, _) = Entity.get_hitbox_dims plat.hitbox in
        let px1 = final_x and px2 = final_x +. w in
        let plat_x1 = plat.position.x and plat_x2 = plat.position.x +. pw in
        (* overlap horizontal ? *)
        if px2 > plat_x1 && px1 < plat_x2 then
          (* est-ce qu’on a croisé le sommet cette frame ? *)
          let old_bot = pos.y +. h in
          let new_bot = clamped_y +. h in
          if old_bot <= plat_top && new_bot >= plat_top then
            Some (plat_top -. h)
          else None
        else None
      ) platforms
    else
      None
  in

  (* on choisit la meilleure collision *)
  let final_y =
    match landing_y_opt with
    | Some landed_y -> landed_y
    | None ->
      if hit_wall || hit_plat_simple then pos.y
      else clamped_y
  in

  let final_vx = if final_x = pos.x then 0.0 else velocity.vx in
  let final_vy = if final_y = pos.y then 0.0 else velocity.vy in

  { player with
    position = { x = final_x; y = final_y };
    velocity = { vx = final_vx; vy = final_vy };
  }


let update_player gs =
  let dt = Raylib.get_frame_time () in 
  (* On met à jour la position du joueur si il est sur une plateforme mobile *)
  let player = move_with_platform gs.player gs.moving_platforms dt in 
  let new_velocity = update_player_movement player gs.map gs.moving_platforms in
  let player_with_velocity = { player with velocity = new_velocity } in
  let temp_gs = { gs with player = player_with_velocity } in
  let updated_player, _, updated_gs = update_player_state_and_damage temp_gs in
  let elapsed_player = Entity.elapse_state updated_player in
  let corrected_player = update_player_position elapsed_player gs.map gs.moving_platforms new_velocity in
  { updated_gs with player = corrected_player }
  

let update_all_enemies (gs : game_state) dt =
  let updated_enemies, updated_objects =
    let updated_position = (List.map (fun enemy ->
      let enemy = update_enemy_position enemy dt gs.map gs.player.position in 
      let new_state = update_enemy_state gs.player enemy in 
      Entity.elapse_state new_state
    ) gs.enemies )
    in
  (* Si les ennemis meurent alors on les retire de la liste *)
  let gs = {gs with enemies = updated_position} in  
  despawn_enemies gs
  in
  { gs with enemies = updated_enemies ; objects = updated_objects}

let update_moving_platforms gs dt = 
  let new_mp = List.map (fun m -> Entity.update_moving_platform m dt) gs.moving_platforms in 
  {gs with moving_platforms = new_mp}

let check_boss_defeat gs =
  if Enemy.is_boss_dead gs then
    raise Menu.EndLevelTriggered
  else
    gs


(* --- Traitement des collisions d'objets --- *)

let process_object_collisions gs =
  let updated_state =
    List.fold_left (fun acc_state obj ->
      (* On applique l'effet des objets sur le joueur *)
      if check_object_collision acc_state.player obj then
        apply_object_effect acc_state obj
      else
        acc_state
    ) gs gs.objects
  in
  let remaining_objects = List.filter (fun obj ->
    not (check_object_collision updated_state.player obj)
  ) updated_state.objects in
  { updated_state with objects = remaining_objects }

let update_player_m = GSMonad.apply update_player
let interact_with_blocks_m = GSMonad.apply interact_with_blocks
let update_all_enemies_m dt = GSMonad.apply (fun gs -> update_all_enemies gs dt)
let damage_player_m dt = GSMonad.apply (fun gs -> damage_player gs dt)
let process_object_collisions_m = GSMonad.apply process_object_collisions
let update_game_state_m config = GSMonad.apply (fun gs -> update_game_state gs config)
let update_objects_m = GSMonad.apply update_objects
let update_moving_platforms_m dt = GSMonad.apply (fun gs -> update_moving_platforms gs dt)


let run_state config = 
  let dt = Raylib.get_frame_time () in 
  let* () = update_player_m in
  let* () = interact_with_blocks_m in
  let* () = update_all_enemies_m dt in
  let* () = damage_player_m dt in
  let* () = process_object_collisions_m in
  let* () = update_game_state_m config in
  let* () = update_objects_m in
  let* () = update_moving_platforms_m dt in
  let* gs = get in
  let _ = check_boss_defeat gs in
  get


let rec game_loop gs config =
  let open Raylib in 
  try
    let computation = run_state config in 

    let final_gs, _ = computation gs in

    begin_drawing ();
    clear_background Color.skyblue;
    render final_gs config;
    end_drawing ();

    if not (window_should_close ()) then
      game_loop final_gs config
    else
      (close_window (); exit 0)
  with Menu.EndLevelTriggered ->
    (* Nettoyage avant d'afficher le menu de fin *)
    end_drawing ();
    Menu.end_level_loop ();
    close_window ();
    exit 0


module Launcher = struct 
  open Raylib
  open Core
  open Menu
  open Levelhandler
  let run () = 
  init_window 0 0 "Shovel Knight";
  set_target_fps 60;
  toggle_fullscreen ();

  let config = Config.initialize (get_screen_height ()) (get_screen_width ()) in

  (* Initialisation du menu *)
  let menu_button = init_menu () in
  let level_buttons = init_level_selection () in

  let rec menu_loop () =
    draw_menu menu_button;
    match update_menu menu_button with
    | ShowLevelSelection ->
        level_selection_loop ()
    | _ ->
        if not (window_should_close ()) then
          menu_loop ()
  
  and level_selection_loop () =
    draw_level_selection level_buttons;
    match update_level_selection level_buttons with
    | StartLevel1 ->
        let initial_state = create_level "Player" "levels/level_one.json" config in
        game_loop initial_state config
    | StartLevel2 ->
        let initial_state = create_level "Player" "levels/level_two.json" config in
        game_loop initial_state config
    | ContinueMenu ->
        if not (window_should_close ()) then
          level_selection_loop ()
    | _ -> level_selection_loop ()
  
  in
  menu_loop ()
end