open Types

let reward obj_skin = 
  match obj_skin with 
  | Gray -> 5
  | Blue -> 10
  | Green -> 15
  | Yellow -> 30
  | Red -> 50
  | Magenta -> 100
  | Chicken -> 5 
  | Sushi -> 2
  | ManaBottle -> 5 
  | ManaJar -> 10
  | _ -> 0

let create_object ?(state=Idle) ?(vx=0.) ?(vy=0.) obj_type px py = 
  let obj = Object {obj_type = obj_type ; collected = false} in 
  {entity_type = obj; 
  position = {x = px ; y = py} ; 
  velocity = {vx = vx ; vy = vy} ; 
  hitbox = Rectangular {width = 1. ; height = 1.}; 
  state = (state,0)}

let check_object_collision player obj =
  match player.hitbox, obj.hitbox with
  | Rectangular { width = pw; height = ph }, Rectangular { width = ow; height = oh } ->
      player.position.x < obj.position.x +. ow &&
      player.position.x +. pw > obj.position.x &&
      player.position.y < obj.position.y +. oh &&
      player.position.y +. ph > obj.position.y
  | _ -> false  (* Cas où on utilise d'autres types de hitbox *)

let apply_object_effect game_state obj =
  match game_state.player.entity_type with
  | Player p -> (
      match obj.entity_type with
      | Object { obj_type = Heal amount; _ } ->
          let health_amount = reward amount in 
          let new_health = min p.max_health (p.current_health + health_amount) in
          let updated_player = { game_state.player with entity_type = Player { p with current_health = new_health } } in
          { game_state with player = updated_player }
      | Object { obj_type = Gold gem; _ } ->
        let amount = reward gem in 
          let updated_player = { game_state.player with entity_type = Player { p with gold = p.gold + amount } } in
          { game_state with player = updated_player }
      | Object {obj_type = Mana mana; _} -> 
        let amount = reward mana in 
        let new_mana = min p.max_mana (p.current_mana + amount) in 
        let updated_player = {game_state.player with entity_type = Player { p with current_mana = new_mana}} in 
        {game_state with player = updated_player}
      | _ -> game_state
    )
  | _ -> game_state

let object_of_string s = 
  match s with 
  | "Gray" -> Gold Gray
  | "Blue" -> Gold Blue
  | "Yellow" -> Gold Yellow
  | "Green" -> Gold Green
  | "Red" -> Gold Red
  | "Magenta" -> Gold Magenta 
  | "Chicken" -> Heal Chicken
  | "ManaBottle" -> Mana ManaBottle
  | _ -> failwith "objet non existant"



let drop_objects gs enemy =
  Random.self_init ();
  let objects = gs.objects in 
  let number_of_drops = if Entity.is_boss enemy gs then 6 else 2 in
  let rec spawn_objects n acc =
    if n <= 0 then acc
    else
      let integer = Random.int 100 in
      let obj =
        if integer < 50 then Blue
        else if integer < 85 then Yellow
        else if integer < 95 then Green
        else Red
      in
      let new_object = create_object ~state:Falling (Gold obj) (enemy.position.x +. float_of_int n) enemy.position.y in
      spawn_objects (n - 1) (new_object :: acc)
  in
  spawn_objects number_of_drops objects
  


let gravity = 0.02
let max_fall_speed = 0.5

let update_object obj gs =
  let map = gs.map in 
  let state, _ = obj.state in
  match state with
  | Falling ->
      let new_vy = min (obj.velocity.vy +. gravity) max_fall_speed in
      let new_pos_y = obj.position.y +. new_vy in
      let future_obj = {
        obj with
        position = { obj.position with y = new_pos_y };
        velocity = { obj.velocity with vy = new_vy }
      } in
      if Player.check_map_collision future_obj map then
        let hitbox_height =
          match obj.hitbox with
          | Rectangular { height; _ } -> height
          | _ -> 0.0
        in
        let y_block = int_of_float (future_obj.position.y +. hitbox_height) in
        let new_y = float_of_int y_block -. hitbox_height in
        {
          future_obj with
          position = { future_obj.position with y = new_y };
          velocity = { vx = 0.0; vy = 0.0 };
          state = (Idle, 0)
        }
      else
        future_obj
  | Throwed ->
    let new_x = obj.position.x +. obj.velocity.vx in
    let new_y = obj.position.y +. obj.velocity.vy in
    let moved_obj = {
      obj with
      position = { x = new_x; y = new_y }
    } in
    if Player.check_map_collision moved_obj map || Entity.check_collision_with_entities obj gs.enemies then
      { moved_obj with state = (Idle, 0); velocity = { vx = 0.0; vy = 0.0 } }
    else
      moved_obj
      
  | _ -> obj

let despawn_objects (objects : game_entity list) : game_entity list =
  List.filter (fun e ->
    match e.entity_type with
    | Object { obj_type = Projectile _; _ } ->
        let (es, _) = e.state in
        es <> Idle
    | _ -> true
  ) objects


let cast_projectile gs =
  match gs.player.entity_type with
  | Player p ->
      let mana_cost = 1 in
      if p.current_mana < mana_cost then gs
      else
        let pw, ph = Entity.get_hitbox_dims gs.player.hitbox in
        let projectile =
          create_object
            ~state:Throwed
            ~vx:0.1
            ~vy:0.
            (Projectile FireBall)
            (gs.player.position.x +. pw)
            (gs.player.position.y +. ph /. 4.)
        in
        let updated_player = {
          gs.player with
          entity_type = Player { p with current_mana = p.current_mana - mana_cost }
        } in
        { gs with player = updated_player; objects = projectile :: gs.objects }
  | _ -> gs



let handle_projectile_collisions obj enemies =
  match obj.entity_type with
  | Object { obj_type = Projectile _; _ } ->
      let collided_enemy =
        List.find_opt (fun e -> Entity.check_entity_collision obj e) enemies
      in
      (match collided_enemy with
      | Some _ ->
          let updated_enemies = List.map (fun e ->
            if Entity.check_entity_collision obj e then
              match e.entity_type with
              | Enemy en ->
                  let new_hp = max 0 (en.current_health - 1) in
                  { e with entity_type = Enemy { en with current_health = new_hp } }
              | _ -> e
            else e
          ) enemies in
          let obj = { obj with state = (Idle, 0); velocity = { vx = 0.; vy = 0. } } in
          (obj, updated_enemies)
      | None -> (obj, enemies))
  | _ -> (obj, enemies)
  
let update_objects gs =
  let rec update_all objs enemies acc =
    match objs with
    | [] -> (List.rev acc, enemies)
    | obj :: rest ->
        let updated_obj = update_object obj gs in
        let final_obj, new_enemies = handle_projectile_collisions updated_obj enemies in
        update_all rest new_enemies (final_obj :: acc)
  in
  let updated_objects, updated_enemies = update_all gs.objects gs.enemies [] in
  let objects = despawn_objects updated_objects in
  { gs with objects = objects; enemies = updated_enemies }
  