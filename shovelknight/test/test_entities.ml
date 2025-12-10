open Shovelknight
open Types

let test_hitbox_dims () =
    let rect = Types.Rectangular { width = 2.5; height = 3.5 } in
    let (w, h) = Entity.get_hitbox_dims rect in
    Alcotest.(check (float 0.01)) "width" 2.5 w;
    Alcotest.(check (float 0.01)) "height" 3.5 h
  
let test_get_bounds () =
  let e = {
    velocity = {vx=8.;vy=6.};
    state = (Idle,1);
    position = { x = 10.; y = 20. };
    hitbox = Types.Rectangular { width = 5.; height = 8. };
    entity_type = Object {obj_type = Gold Magenta ; collected = false}
  } in
  let (x, y, w, h) = Entity.get_bounds e in
  Alcotest.(check (float 0.01)) "x" 10. x;
  Alcotest.(check (float 0.01)) "y" 20. y;
  Alcotest.(check (float 0.01)) "width" 15. w;
  Alcotest.(check (float 0.01)) "height" 28. h


let test_health_functions () =
  let open QCheck in 
  let enemy = Enemy.create_beeto 0. 0. in
  let player = Generators.gen_player_entity |> Gen.generate1 in
  
  Alcotest.(check int) "current health enemy" 3 (Entity.get_current_health enemy);
  Alcotest.(check int) "max health enemy" 3 (Entity.get_max_health enemy);
  Alcotest.(check int) "current health player" 100 (Entity.get_current_health player);
  Alcotest.(check int) "max health player" 100 (Entity.get_max_health player)

let test_is_dead () =
  let alive = Enemy.create_beeto 0. 0. in
  let dead = { alive with 
    entity_type = match alive.entity_type with
    | Types.Enemy e -> Types.Enemy { e with current_health = 0 }
    | _ -> failwith "not enemy"
  } in
  Alcotest.(check bool) "alive" false (Entity.is_dead alive);
  Alcotest.(check bool) "dead" true (Entity.is_dead dead)



let test_attack_timing () =
  let e = Enemy.create_beeto 0. 0. in
  let initial_time = Entity.get_attack_time e in
  let updated = Entity.update_attack_time e 0.1 in
  let new_time = Entity.get_attack_time updated in
  Alcotest.(check (float 0.01)) "cooldown changed" 0.1 new_time;
  
  let initial_cd = Entity.update_attack_time e initial_time in
  Alcotest.(check (float 0.01)) "cooldown zero" 0.5 (Entity.get_attack_time initial_cd)


let test_state_management () =
  let e = { 
    (Enemy.create_beeto 0. 0.) with 
    state = (Types.Attacking, 1) 
  } in
  let updated = Entity.elapse_state e in
  let (state, frame) = updated.state in
  Alcotest.(check bool) "state changed" true (frame > 1 || state <> Types.Attacking)
  
let test_is_moving () =
  let static = Enemy.create_blorb 0. 0. in
  let moving = { static with velocity = { vx = 1.; vy = 0. } } in
  Alcotest.(check bool) "static" false (Entity.is_moving static);
  Alcotest.(check bool) "moving" true (Entity.is_moving moving)


let test_moving_platform () =
  let platform = {
    position = { x = 0.; y = 0. };
    velocity = { vx = 2.; vy = 0. };
    hitbox = Types.Rectangular { width = 10.; height = 1. };
    entity_type = MovingPlatform {skin=Solid Grass ; movement=(2.,2.)};
    state = (Idle,1)
  } in
  let updated = Entity.update_moving_platform platform 1.0 in
  Alcotest.(check (float 0.01)) "platform moved" 2. updated.position.x;
  
  let (start, dist) = Entity.get_platform_movement updated in
  Alcotest.(check (float 0.01)) "movement x" 2. start;
  Alcotest.(check (float 0.01)) "movement y" 2. dist


let test_collisions () =
  let e1 = Enemy.create_boneclang 0. 1. in
  let e2 = { e1 with position = { x = 1.; y = 1. } } in (* Chevauchement *)
  let e3 = { e1 with position = { x = 3.; y = 3. } } in (* Pas de collision *)
  
  Alcotest.(check bool) "colliding" true (Entity.check_entity_collision e1 e2);
  Alcotest.(check bool) "not colliding" false (Entity.check_entity_collision e1 e3);
  
  let entities = [e2; e3] in
  Alcotest.(check bool) "list collision" true (Entity.check_collision_with_entities e1 entities)


let test_boss_detection () =
  let open QCheck in 
  let gs = Generators.gen_game_state |> Gen.generate1 in
  let boss = { (Enemy.create_dozedrake 0. 0.) with 
    entity_type = match (Enemy.create_dozedrake 0. 0.).entity_type with
    | Types.Enemy e -> Types.Enemy { e with skin = gs.boss }
    | _ -> failwith "not enemy"
  } in
  let normal_enemy = Enemy.create_beeto 0. 0. in
  
  Alcotest.(check bool) "is boss" true (Entity.is_boss boss gs);
  Alcotest.(check bool) "not boss" false (Entity.is_boss normal_enemy gs)


    let () =
    Alcotest.run "Entity Tests" [
      ("Hitbox", [
        Alcotest.test_case "Dimensions" `Quick test_hitbox_dims;
        Alcotest.test_case "Bounds" `Quick test_get_bounds;
      ]);
      ("Health", [
        Alcotest.test_case "Health values" `Quick test_health_functions;
        Alcotest.test_case "Death check" `Quick test_is_dead;
      ]);
      ("Combat", [
        Alcotest.test_case "Attack timing" `Quick test_attack_timing;
      ]);
      ("Movement", [
        Alcotest.test_case "State updates" `Quick test_state_management;
        Alcotest.test_case "Movement detection" `Quick test_is_moving;
      ]);
      ("Platforms", [
        Alcotest.test_case "Moving platform" `Quick test_moving_platform;
      ]);
      ("Collisions", [
        Alcotest.test_case "Entity collisions" `Quick test_collisions;
      ]);
      ("Boss", [
        Alcotest.test_case "Boss detection" `Quick test_boss_detection;
      ]);
    ]