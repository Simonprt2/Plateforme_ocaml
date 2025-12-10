open Types
open Player
open Entity
open Core.Collision
open Object
open Core.Config
open Core.Map

(* initialise un ennemi ainsi que ses propriétés*)
let initialize_enemy skin attack_type enemy_movement health max_health position hitbox_height hitbox_width =
  let struct_enemy = Enemy {
    skin = skin;
    attack_type = attack_type;
    enemy_movement = enemy_movement;
    current_health = health;
    max_health = max_health;
    attack_time = 0.5;
    cooldown = 0.5;
  } in
  {
    entity_type = struct_enemy;
    position = position;
    velocity = { vx = 0.; vy = 0.0 };
    hitbox = Rectangular { width = hitbox_width; height = hitbox_height };
    state = Idle,1;
  }

(* fonction de creation de nos ennemis*)
let create_beeto x y =
  initialize_enemy Beeto (Melee 1) (Patrol (x,3.0)) 3 3 { x = x; y = y } 1. 2.

let create_blorb x y =
  initialize_enemy Blorb (Melee 0) Static 5 5 { x = x; y = y } 1. 1.

let create_boneclang x y =
  initialize_enemy Boneclang (Melee 1) (Patrol (x,2.0)) 5 5 { x = x; y = y } 2. 2.

let create_dozedrake x y =
  initialize_enemy Dozedrake (Range (2, 5.0)) (StaticChase false) 10 10 { x = x; y = y } 4. 6.

let create_firedrake x y =
  initialize_enemy Firedrake (Range (1, 5.0)) Chase 6 6 { x = x; y = y } 2. 2.

let create_goldarmor x y =
  initialize_enemy Goldarmor (Melee 1) (Patrol (x,2.0)) 8 8 { x = x; y = y } 2. 2.

let create_hoppicles x y =
  initialize_enemy Hoppicles (Melee 1) (Patrol (x,2.0)) 10 10 { x = x; y = y } 2.5 2.5

let create_moller x y =
  initialize_enemy Moller (Melee 1) (Patrol (x,2.0)) 3 3 { x = x; y = y } 1.2 2.



let spawn_enemy enemy map x =
  let enemy_height, _ = Entity.get_hitbox_dims enemy.hitbox in 

  let column_index = int_of_float x in

  match find_ground_y map column_index with
  | Some ground_y ->
      let enemy_y = (float_of_int ground_y) -. enemy_height |> floor in
      { enemy with position = { x = x; y = enemy_y } }
  | None -> 
      enemy 


(* fonction de mouvement des ennemis, selon leur comportement*)
let update_enemy_position enemy dt map player_position =
  let (state, _) = enemy.state in
  match enemy.entity_type with
  | Enemy e ->
    let new_velocity =
      if state = Attacking then
        { vx = 0.0; vy = 0.0 }
      else
        match e.enemy_movement with
        | Static -> { vx = 0.0; vy = 0.0 }
    
        | Patrol (spawn_x, distance) ->
            let current_vx =
              if enemy.velocity.vx = 0.0 then
                let initial_speed = 1.0 in
                if enemy.position.x >= spawn_x then -.initial_speed else initial_speed
              else enemy.velocity.vx
            in
            if enemy.position.x >= spawn_x +. distance then
              { enemy.velocity with vx = -.abs_float current_vx }
            else if enemy.position.x <= spawn_x -. distance then
              { enemy.velocity with vx = abs_float current_vx }
            else
              { enemy.velocity with vx = current_vx }
    
        | Chase ->
            let dx = player_position.x -. enemy.position.x in
            let dy = player_position.y -. enemy.position.y in
            let distance = sqrt (dx ** 2. +. dy ** 2.) in
            let speed = 1.5 in
            if distance > 0. then
              { vx = (dx /. distance) *. speed; vy = (dy /. distance) *. speed }
            else enemy.velocity
    
        | StaticChase alerted ->
            let dx = player_position.x -. enemy.position.x in
            let abs_dx = abs_float dx in
            let threshold = 2.0 in
            if alerted || abs_dx < threshold then
              let direction = if dx > 0. then 1. else -1. in
              { vx = direction *. 0.8; vy = 0.0 }
            else
              { vx = 0.0; vy = 0.0 }
    
      in

      let new_position = {
        x = enemy.position.x +. new_velocity.vx *. dt;
        y = enemy.position.y +. new_velocity.vy *. dt;
      } in

      let updated_entity_type =
        match e.enemy_movement with
        | StaticChase alerted ->
            let dx = player_position.x -. enemy.position.x in
            let abs_dx = abs_float dx in
            let threshold = 2.0 in
            if not alerted && abs_dx < threshold then
              Enemy { e with enemy_movement = StaticChase true }
            else
              enemy.entity_type
        | _ -> enemy.entity_type
      in

      let future_enemy = { enemy with position = new_position; velocity = new_velocity; entity_type = updated_entity_type } in

      if check_map_collision future_enemy map then
        { enemy with velocity = { vx = 0.0; vy = 0.0 }; entity_type = updated_entity_type }
      else
        future_enemy

  | _ -> enemy
      

(*fonction de dégat au joueur*)
let attack_enemy enemy player =
  match enemy.entity_type with
  | Enemy e ->
      let distance_to_player = sqrt ((player.position.x -. enemy.position.x) ** 2.0 +. (player.position.y -. enemy.position.y) ** 2.0) in
      let damage =
        match e.attack_type with
        | Melee dmg when distance_to_player < 1.0 -> Some dmg
        | Range (dmg, range) when distance_to_player < range -> Some dmg
        | _ -> None
      in
      (match damage with
      | Some dmg -> (
          match player.entity_type with
          | Player p ->
              let new_health = max 0 (p.current_health - dmg) in
              { player with entity_type = Player { p with current_health = new_health } }
          | _ -> player
        )
      | None -> player)
  | _ -> failwith "attack_enemy should only be called on enemies"

  

let enemy_of_string s = 
  match s with 
  | "Beeto" -> Beeto 
  | "Blorb" -> Blorb
  | "Boneclang" -> Boneclang
  | "Firedrake" -> Firedrake
  | "Dozedrake" -> Dozedrake
  | "Goldarmor" -> Goldarmor
  | "Hoppicles" -> Hoppicles
  | "Moller" -> Moller
  | _ -> failwith ("pas d implementation pour " ^ s)

let string_of_enemy e = 
  match e with 
  | Beeto -> "Beeto"
  | Blorb -> "Blorb"
  | Boneclang -> "Boneclang"
  | Firedrake -> "Firedrake"
  | Dozedrake -> "Dozedrake"
  | Goldarmor -> "Goldarmor"
  | Hoppicles -> "Hoppicles"
  | Moller -> "Moller"

(* fonction de "mort" de l'ennemi*)
let despawn_enemies gs =
  let enemies = gs.enemies in 
  let objects = gs.objects in 
  let objects =
    List.fold_left
      (fun objs enemy ->
        if get_current_health enemy <= 0 then
          drop_objects gs enemy
        else
          objs)
      objects enemies
  in
  let enemies = List.filter (fun enemy -> get_current_health enemy > 0) enemies in
  (enemies, objects)
  

let get_cooldown entity = 
  match entity.entity_type with 
  | Enemy e -> e.cooldown 
  | _ -> failwith "ENEMY pas de cooldown"

let update_enemy_timer enemy (dt : float) =
  let timer = get_attack_time enemy in
  let new_timer = max 0.0 (timer -. dt) in
  update_attack_time enemy new_timer



let damage_player gs dt =
  let near_enemies = get_colliding_enemies gs in
  let updated_enemies, updated_player =
    List.fold_left (fun (acc_enemies, player) enemy ->
      let is_near = List.mem enemy near_enemies in
      let enemy = update_enemy_timer enemy dt in
      let timer = get_attack_time enemy in
      let cd = get_cooldown enemy in

      if is_near && timer <= 0.0 then
        let enemy_attacked = update_attack_time enemy cd in
        (enemy_attacked :: acc_enemies, attack_enemy enemy player)
      else
        (enemy :: acc_enemies, player)
    ) ([], gs.player) gs.enemies
  in
  { gs with player = updated_player; enemies = updated_enemies }
  
  
let distance p1 p2 =
  let dx = p1.x -. p2.x in
  let dy = p1.y -. p2.y in
  sqrt (dx *. dx +. dy *. dy)

    
let closest_enemy player enemies =
  let player_position = player.position in 
  match enemies with
  | [] -> failwith "Pas d'ennemis en vue"
  | hd :: tl ->
      let init_dist = distance player_position hd.position in
      let closest, _ =
        List.fold_left (fun (closest_enemy, min_dist) enemy ->
          let d = distance player_position enemy.position in
          if d < min_dist then (enemy, d)
          else (closest_enemy, min_dist)
        ) (hd, init_dist) tl
      in
      closest
    
  
let player_enemy_collision player enemy =
  match player.hitbox, enemy.hitbox with
  | Rectangular { width = pw; height = ph },
    Rectangular { width = ew; height = eh } ->
      rectangles_collide player.position (pw, ph) enemy.position (ew, eh)
  | _ -> false

let get_enemy_skin entity = 
  match entity.entity_type with 
  | Enemy e -> e.skin
  | _ -> failwith "ERREUR PAS DE SKIN SUR ENNEMI"


let update_enemy_state player enemy = 
  let (old_state, old_timer) = enemy.state in 
  let new_state = 
    if player_enemy_collision player enemy then 
      if old_state = Attacking then (Attacking, old_timer)
      else (Attacking,0)
    else if is_moving enemy && ((get_enemy_skin enemy) = Firedrake || (get_enemy_skin enemy) = Dozedrake || (get_enemy_skin enemy) = Boneclang || (get_enemy_skin enemy) = Goldarmor || (get_enemy_skin enemy) = Hoppicles || (get_enemy_skin enemy) = Moller) then 
      if old_state = Running then (Running, old_timer)
      else (Running,0)
    else 
      if old_state = Attacking then (Idle, 0) 
      else (old_state, old_timer)
    in {enemy with state = new_state}


let is_enemy_visible enemy camera config =
  let ex = enemy.position.x in
  let ey = enemy.position.y in
  let (ew, eh) = get_hitbox_dims enemy.hitbox in

  let cam_x = camera.cx in
  let cam_y = camera.cy in
  let screen_blocks_x = float_of_int config.screen_width /. config.block_width in
  let screen_blocks_y = float_of_int config.screen_height /. config.block_height in

  ex +. ew >= cam_x &&
  ex <= cam_x +. screen_blocks_x &&
  ey +. eh >= cam_y &&
  ey <= cam_y +. screen_blocks_y


let is_boss_dead gs = 
  List.for_all (fun e -> 
    match e.entity_type with
    | Enemy e -> e.skin <> gs.boss
    | _ -> true
  ) gs.enemies
  
  