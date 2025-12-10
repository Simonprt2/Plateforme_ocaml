(* player.ml *)
open Types
open Core.Collision
open State
open Entity
open Raylib
open Core.Map

let initialize_player name =
  let struct_player = Player {
    name = name;
    armor = StalwartPlate;
    attack = 1;
    spells = [];
    max_mana = 30;
    max_health = 8;
    current_mana = 25;
    current_health = 8;
    gold = 0;
    attack_time = 0.;
  } in
  {
    entity_type = struct_player;
    position = { x = 0.; y = 0. };
    velocity = { vx = 0.; vy = 0.};
    hitbox = Rectangular { width = 2.; height = 2. }; 
    state = (Idle,1);
  }


let update_position player new_x new_y =
  { player with position = { x = new_x; y = new_y } }


let spawn_player player map x =
  let (_,player_height) = Entity.get_hitbox_dims player.hitbox in 

  let column_index = int_of_float x in

  match find_ground_y map column_index with
  | Some ground_y ->
      let player_y = (float_of_int ground_y) -. player_height |> floor in
      update_position player x player_y
  | None -> 
      player
  
let is_on_platform player platform =
  let (pl, _, pr, pb) = get_bounds player in
  let (ml, mt, mr, _) = get_bounds platform in
  let epsilon = 0.1 in

  let horizontally_aligned = pr > ml +. epsilon && pl < mr -. epsilon in
  let vertically_aligned = abs_float (pb -. mt) < epsilon in

  horizontally_aligned && vertically_aligned


let is_on_ladder player map =
  let (w, h) = get_hitbox_dims player.hitbox in
  let center_x = player.position.x +. w /. 2. in
  let center_y = player.position.y +. h /. 2. in
  let tile_x = int_of_float center_x in
  let tile_y = int_of_float center_y in
  
  tile_y >= 0 && tile_y < Array.length map &&
  tile_x >= 0 && tile_x < Array.length map.(0) &&
  (match map.(tile_y).(tile_x) with 
   | Interactive Ladder -> true 
   | _ -> false)


let check_map_collision entity map =
  let { position = { x; y }; hitbox; _ } = entity in
  let (width, height) = get_hitbox_dims hitbox in 
      let x_min = int_of_float x in
      let x_max = int_of_float (x +. width -. 0.01) in
      let y_min = int_of_float y in
      let y_max = int_of_float (y +. height -. 0.01) in
      List.exists (fun i ->
        List.exists (fun j ->
          match map.(i).(j) with Solid _ -> true | _ -> false
        ) (List.init (x_max - x_min + 1) (fun k -> x_min + k))
      ) (List.init (y_max - y_min + 1) (fun k -> y_min + k))

let check_platform_collision entity mps = 
  List.exists (is_on_platform entity) mps
    
    
let update_player_hitbox gs w h = 
  let updated_player = {gs.player with hitbox = Rectangular {width = w; height = h}} in 
  {gs with player = updated_player}
    
      

let update_player_state (game: game_state) (new_state: state) : game_state =
  match game.player.entity_type with
  | Player _ -> 
      let updated_hitbox = 
      (match (get_sprite_index game.player) with 
      | Attacking,2 -> update_player_hitbox game 3. 2.
      | Attacking,_ -> update_player_hitbox game 2. 2.
      | Idle,_ -> update_player_hitbox game 2. 2. 
      | Running,_ -> update_player_hitbox game 2.35 2.
      | Jumping,_ -> update_player_hitbox game 2. 2. 
      | Falling,_ -> update_player_hitbox game 2. 2.
      | Climbing,_ -> update_player_hitbox game 2. 2.
      | Throwed, _ -> update_player_hitbox game 2. 2.
      ) in 
      let updated_player = 
        { updated_hitbox.player with state = new_state }
      in
      { updated_hitbox with player = updated_player }
  | _ -> game

let update_player_attack game atk = 
  match game.player.entity_type with
  | Player p -> 
    let new_player = {game.player with entity_type = Player {p with attack = atk}} in 
    {game with player = new_player}
    | _ -> failwith "impossible"
  
let string_of_state s = 
  let (es,k) = s in 
  (match es with 
  | Idle -> "Idle"
  | Attacking -> "Attacking"
  | Running -> "Running"
  | Jumping -> "Jumping"
  | Falling -> "Falling"
  | Climbing -> "Climbing"
  | Throwed -> "Throwed"
  ) ^ "," ^ string_of_int k

let get_player_state player =
  match player.entity_type with
  | Player _ -> player.state
  | _ -> failwith "Pas un joueur"

let get_player_attack_time player = 
  match player.entity_type with 
  | Player p -> p.attack_time
  | _ -> failwith "pas un joueur"

  let update_attack_time (game: game_state) new_attack_time : game_state =
    match game.player.entity_type with
    | Player p -> 
        let updated_player = 
          { game.player with entity_type = Player { p with attack_time = new_attack_time } }
        in
        { game with player = updated_player }
    | _ -> game

let damage_enemy player enemy =
  let damage =
    match player.entity_type with
    | Player p -> p.attack
    | _ -> failwith "erreur: l'entité player n'est pas un joueur"
  in
  match enemy.entity_type with 
  | Enemy e -> { enemy with entity_type = Enemy { e with current_health = e.current_health - damage } }
  | _ -> failwith "erreur: l'entité enemy n'est pas un ennemi"
  

  let inflict_damage_around gs =
    let enemies_around = get_colliding_enemies gs in
    let update_enemy enemy =
      if List.exists (fun e -> e.entity_type = enemy.entity_type) enemies_around then
        damage_enemy gs.player enemy
      else
        enemy
    in
    let updated_enemies = List.map update_enemy gs.enemies in
    { gs with enemies = updated_enemies; }
  

let reset_player player map = 
  match player.entity_type with 
  | Player p -> 
    let new_health = (get_max_health player) / 2 in 
    let new_gold = p.gold / 4 in  
    let new_player = 
      {player with 
      entity_type = Player {p with current_health = new_health ; gold = new_gold} ; 
      velocity = {vx = 0.1 ; vy = 0.2} ; 
      state = (Idle,1)} 
    in 
    spawn_player new_player map 2.

  | _ -> failwith "PLAYER pas un player"

let kill_player player = 
  match player.entity_type with 
  | Player p -> {player with entity_type = Player {p with current_health = 0}}
  | _ -> failwith "PLAYER pas un player"


let interact_with_blocks gs = 
  let block_under_player player =
    let (hw, hh) = get_hitbox_dims player.hitbox in 
        let foot_x = player.position.x +. hw /. 2. in
        let foot_y = player.position.y +. hh in
        let (x,y) = (int_of_float foot_x, int_of_float foot_y) in 
        gs.map.(y).(x)
  in 
  let block_at_center player =
    let (w, h) = get_hitbox_dims player.hitbox in
    let center_x = int_of_float (player.position.x +. w /. 2.) in
    let center_y = int_of_float (player.position.y +. h /. 2.) in
    gs.map.(center_y).(center_x)
  in
  match block_under_player gs.player, block_at_center gs.player with
  | Hostile _, _ -> let new_player = kill_player gs.player in {gs with player = new_player}
  | _, Interactive Ladder -> gs
  | _, Interactive Lever -> 
      if is_key_down Raylib.Key.Enter then (
        print_endline "Lever activated!";  (* Debug *)
        raise Menu.EndLevelTriggered
      ) else 
        gs
  | _ -> gs


let get_player_name player = 
  match player.entity_type with 
  | Player p -> p.name 
  | _ -> failwith "PLAYER pas de nom"


let move_with_platform player moving_platforms dt =
  match List.find_opt (is_on_platform player) moving_platforms with
  | Some platform ->
      let dx = platform.velocity.vx *. dt in
      {
        player with
        position = {
          x = player.position.x +. dx;
          y = platform.position.y -. (snd (get_hitbox_dims player.hitbox));
        }
      }
  | None -> player


let is_on_ground player map platforms =
  let (w, h) = get_hitbox_dims player.hitbox in
  let foot_x = player.position.x +. w /. 2. in
  let foot_y = player.position.y +. h +. 0.05 in
  let tile_x = int_of_float foot_x in
  let tile_y = int_of_float foot_y in
  let on_block = 
    tile_y >= 0 && tile_y < Array.length map &&
    tile_x >= 0 && tile_x < Array.length map.(0) &&
    (match map.(tile_y).(tile_x) with Solid _ -> true | _ -> false)
  in
  let on_platform =
    List.exists (fun platform ->
      let (pw, _) = get_hitbox_dims platform.hitbox in
      let platform_left = platform.position.x in
      let platform_right = platform.position.x +. pw in
      let platform_top = platform.position.y in
      foot_x > platform_left && foot_x < platform_right &&
      abs_float (foot_y -. platform_top) < 0.2
    ) platforms
  in
  on_block || on_platform


  