open QCheck
open Gen
open Shovelknight
open Types

let gen_map = 
    let map = Array.make_matrix 100 100 (Empty) in 
    Array.fill (map.(98)) 0 100 (Solid Grass);
    Array.fill (map.(99)) 0 100 (Solid Grass);
    map


let map5 f x1 x2 x3 x4 x5 = map2 (fun (a, b, c) (d, e) -> f a b c d e)
(map3 (fun a b c -> (a, b, c)) x1 x2 x3)
(map2 (fun a b -> (a,b)) x4 x5)


let gen_float = float_range 0. 100. 

let gen_position = map2 (fun x y -> {x ; y}) gen_float gen_float

let gen_velocity : velocity t = map2 (fun vx vy -> {vx ; vy}) gen_float gen_float 

let gen_state = 
    map2 (fun es k -> (es,k)) 
    (oneofl [Idle; Running; Attacking; Jumping; Falling; Throwed])
    (int_bound 10)

let gen_rect_hitbox =
    let open Gen in
    map (fun (w, h) -> Rectangular { width = w; height = h })
        (pair (float_range 1. 10.) (float_range 1. 10.))


let gen_enemy_skin = Gen.oneofl [Beeto; Blorb; Boneclang; Dozedrake; Firedrake]

let gen_attack_type =
    let open Gen in
    oneof [
    map (fun d -> Melee d) (int_bound 10);
    map2 (fun d r -> Range (d, r)) (int_bound 10) (float_range 0.1 10.)
    ]

let gen_enemy_movement =
    let open Gen in
    oneof [
    return Static;
    map2 (fun a b -> Patrol (a, b)) gen_float gen_float;
    return Chase;
    map (fun b -> StaticChase b) bool
    ]


let gen_enemy_entity : game_entity Gen.t =
    map5 (fun position velocity hitbox state skin ->
        {
        entity_type = Enemy {
            skin = skin;
            attack_type = Melee 5;
            enemy_movement = Static;
            current_health = 10;
            max_health = 10;
            attack_time = 1.0;
            cooldown = 1.0;
        };
        position;
        velocity;
        hitbox;
        state;
        })
        gen_position gen_velocity gen_rect_hitbox gen_state gen_enemy_skin
    


let gen_player_entity : game_entity Gen.t =
    map5 (fun position velocity hitbox state name ->
        {
        entity_type = Player {
            name = name;
            armor = StalwartPlate;
            attack = 10;
            spells = [FlareWand];
            max_mana = 100;
            max_health = 100;
            current_mana = 100;
            current_health = 100;
            gold = 0;
            attack_time = 1.0;
        };
        position;
        velocity;
        hitbox;
        state;
        })
        gen_position gen_velocity gen_rect_hitbox gen_state (string_size (return 5))
          


let gen_game_state : game_state Gen.t =
    map2 (fun player enemies ->
        {
        camera = { cx = 0.; cy = 0. };
        map = gen_map;
        player;
        name = Plains_of_passage;
        boss = Dozedrake;
        music = "";
        enemies;
        moving_platforms = [];
        objects = [];
        })
        gen_player_entity (list_size (int_bound 5) gen_enemy_entity)
    