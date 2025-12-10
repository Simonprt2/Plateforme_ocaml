open Types
open Core.Hitbox

let hitbox_of_state state = 
    match state with 
    | Attacking -> make_rectangular 2.7 2.
    | Idle -> make_rectangular 2. 2.
    | _ -> failwith ""

let get_entity_state state = 
    let (es,_) = state in es

let initialize_state entity_state = 
    (entity_state,1)

let get_animation_delay state =
    match get_entity_state state with 
    | Attacking -> 20
    | Running -> 50
    | Idle -> 50
    | Climbing -> 25
    | _ -> 1 

let get_frames_state entity =
    let state = get_entity_state entity.state in
    match entity.entity_type with
    | Player _ ->
        (match state with
            | Attacking -> 4
            | Running -> 6
            | Climbing -> 2
            | _ -> 1)
    | Enemy e ->
        (match e.skin, state with
            | Boneclang, Running -> 4
            | Firedrake, Attacking -> 4
            | Boneclang, Attacking -> 2
            | Beeto, Running -> 3
            | Dozedrake, Idle -> 11
            | Dozedrake, Attacking -> 3
            | Dozedrake, Running -> 6
            | Goldarmor, Running -> 4
            | Moller, Running -> 4
            | Moller, Attacking-> 2
            | Goldarmor, Attacking -> 2
            | Hoppicles, Attacking -> 2
            
            | _, Running -> 2
            | _, _ -> 1)
    | _ -> 1
    

let get_sprite_index entity  =
    let state = entity.state in 
    let (et, timer) = state in
    let animation_duration = get_animation_delay state in
    let nb_frames = get_frames_state entity in
    let timer_mod = timer mod animation_duration in
    let index = (timer_mod * nb_frames) / animation_duration + 1 in
    et, min index nb_frames
