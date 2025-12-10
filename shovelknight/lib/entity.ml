open Types 

let get_hitbox_dims hitbox = 
    match hitbox with 
    | Rectangular { width; height } -> (width, height)
    | _ -> failwith "Pas de hitbox rectangulaire"
  
  let get_bounds entity =
    let (w, h) = get_hitbox_dims entity.hitbox in
    let x = entity.position.x in
    let y = entity.position.y in
    (x, y, x +. w, y +. h)

let get_current_health entity = 
    match entity.entity_type with 
    | Player p -> p.current_health
    | Enemy e -> e.current_health
    | _ -> failwith "N'a pas de vie"


let get_max_health entity = 
    match entity.entity_type with 
    | Player p -> p.max_health
    | Enemy e -> e.max_health
    | _ -> failwith "N'a pas de vie"

let get_attack_time entity = 
    match entity.entity_type with 
    | Player p -> p.attack_time
    | Enemy e -> e.attack_time
    | _ -> failwith "ENTITY N'a pas d'attack time"


let print_entity entity =
    match entity.entity_type with
    | Player p ->
        Printf.printf "%s (%.1f, %.1f)\n" p.name entity.position.x entity.position.y
    | Enemy e -> Printf.printf "Enemy (%.1f, %.1f) , PV : %d \n" entity.position.x entity.position.y e.current_health
    | MovingPlatform _ -> Printf.printf "Platform (%.1f, %.1f)\n" entity.position.x entity.position.y
    | Object _ -> Printf.printf "Object (%.1f, %.1f)\n" entity.position.x entity.position.y

let update_attack_time entity a = 
    match entity.entity_type with 
    | Player p -> {entity with entity_type = Player { p with attack_time = a }}
    | Enemy e -> {entity with entity_type = Enemy { e with attack_time = a }}
    | _ -> failwith "Impossible pas un joueur/ennemi"

let print_entities entities  =
List.iter print_entity entities

let is_dead entity = 
    get_current_health entity = 0

let elapse_state entity = 
    let (es,k) = entity.state in 
    {entity with state = (es,k+1)}


let is_moving entity = 
    entity.velocity.vx <> 0. || entity.velocity.vy <> 0.


let get_position entity = 
    (entity.position.x, entity.position.y)

let is_boss entity gs = 
    match entity.entity_type with 
    | Enemy e -> e.skin = gs.boss
    | _ -> failwith "ENTITY pas un ennemi"


let update_moving_platform entity dt =
    match entity.entity_type with
    | MovingPlatform m ->
        let (spawn_x, distance) = m.movement in
        let vx =
            if entity.velocity.vx = 0.0 then
            let initial_speed = 1.0 in
            if entity.position.x >= spawn_x then -.initial_speed else initial_speed
            else entity.velocity.vx
        in
        let new_vx =
            if entity.position.x >= spawn_x +. distance then
            -.abs_float vx
            else if entity.position.x <= spawn_x -. distance then
            abs_float vx
            else
            vx
        in
        let new_x = entity.position.x +. new_vx *. dt in
        {
            entity with
            velocity = { entity.velocity with vx = new_vx };
            position = { entity.position with x = new_x };
        }
    | _ -> failwith "ENTITY pas une plateforme"

let get_platform_movement entity = 
    match entity.entity_type with 
    | MovingPlatform m -> m.movement 
    | _ -> failwith "ENTITY pas une plateforme"

let check_entity_collision e1 e2 = 
    let open Core.Collision in
    let p_e1 = e1.position in 
    let p_e2 = e2.position in 
    let h_e1 = get_hitbox_dims e1.hitbox in 
    let h_e2 = get_hitbox_dims e2.hitbox in 
    rectangles_collide p_e1 h_e1 p_e2 h_e2

let check_collision_with_entities e es = List.exists (check_entity_collision e) es



      
