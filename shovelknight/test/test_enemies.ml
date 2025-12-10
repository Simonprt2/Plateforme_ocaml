open Shovelknight
open Enemy 
open Types
open Core


let check_health name enemy =
    let { entity_type; _ } = enemy in
    match entity_type with
    | Enemy e ->
        Alcotest.(check bool) (name ^ " current_health > 0") true (e.current_health > 0);
        Alcotest.(check bool) (name ^ " max_health > 0") true (e.max_health > 0)
    | _ -> Alcotest.fail (name ^ " is not an Enemy")
  ;;
  
let test_create_beeto () = check_health "Beeto" (create_beeto 0. 0.)
let test_create_blorb () = check_health "Blorb" (create_blorb 0. 0.)
let test_create_boneclang () = check_health "Boneclang" (create_boneclang 0. 0.)
let test_create_dozedrake () = check_health "Dozedrake" (create_dozedrake 0. 0.)
let test_create_firedrake () = check_health "Firedrake" (create_firedrake 0. 0.)

let test_attack_enemy () =
    let attacker = Player.initialize_player "attacker" in
    let target = create_beeto 0. 0. in
    match target.entity_type with
    | Enemy _ ->
        let old_health =
          match attacker.entity_type with
          | Player p -> p.current_health
          | _ -> Alcotest.fail "Attacker should be a Player"
        in
        let new_attacker = attack_enemy target attacker in
        (match new_attacker.entity_type with
         | Player p' ->
             Alcotest.(check bool) "health decreased" true (p'.current_health < old_health)
         | _ -> Alcotest.fail "Attacker should still be a Player")
    | _ -> Alcotest.fail "Target should be an Enemy"
  

let test_string_conversion () =
    let open Types in
    let all_skins = [Beeto; Blorb; Boneclang; Dozedrake; Firedrake] in
    List.iter (fun skin ->
      let s = string_of_enemy skin in
      let restored = enemy_of_string s in
      Alcotest.(check bool) ("Round trip for " ^ s) true (restored = skin)
    ) all_skins

let test_static_enemy_does_not_move () =
    let pos = { x = 0.; y = 0. } in
    let enemy = create_blorb 0. 0. in
    let map = Generators.gen_map in
    let new_enemy = update_enemy_position enemy 1.0 map pos in
    Alcotest.(check bool) "Static enemy did not move"
      true
      (enemy.position.x = new_enemy.position.x)
  
  let test_patrol_enemy_moves () =
    let pos = { x = 0.; y = 0. } in
    let enemy = { (create_boneclang 20. 0.) with
      entity_type = match (create_boneclang 20. 0.).entity_type with
        | Enemy e -> Enemy { e with enemy_movement = Patrol (0., 100.) }
        | _ -> failwith "Should be enemy"
    } in
    let map = Generators.gen_map in
    let new_enemy = update_enemy_position enemy 1.0 map pos in
    Alcotest.(check bool) "Patrol enemy moved"
      false
      (enemy.position.x = new_enemy.position.x)


let test_spawn_enemy_position () =
    let map = Generators.gen_map in
    let e = spawn_enemy (create_beeto 50. 0.) map 50. in
    let config = Config.initialize 1200 800 in 
    Alcotest.(check bool) "Spawn above ground" true (e.position.y < 98. *. config.block_height)


let test_despawn_dead () =
    let open QCheck in 
    let base_gs = Gen.generate1 Generators.gen_game_state in
    let dead_enemy = { (create_beeto 0. 0.) with 
        entity_type = match (create_beeto 0. 0.).entity_type with
        | Enemy en -> Enemy { en with current_health = 0 }
        | _ -> failwith "" } in
    
    let gs' = { base_gs with enemies = dead_enemy :: base_gs.enemies } in
    let base_enemies_size = gs'.enemies |> List.length in  
    let (remaining, _) = despawn_enemies gs' in
    let remaining_size = remaining |> List.length in 
    Alcotest.(check bool) "Dead enemy removed" true (base_enemies_size = 0 || base_enemies_size - 1 = remaining_size)
  

let () =
Alcotest.run "Enemy creation tests" [
"health checks", [
    Alcotest.test_case "create_beeto" `Quick test_create_beeto;
    Alcotest.test_case "create_blorb" `Quick test_create_blorb;
    Alcotest.test_case "create_boneclang" `Quick test_create_boneclang;
    Alcotest.test_case "create_dozedrake" `Quick test_create_dozedrake;
    Alcotest.test_case "create_firedrake" `Quick test_create_firedrake;
    Alcotest.test_case "attack_enemy" `Quick test_attack_enemy;
    Alcotest.test_case "string round-trip" `Quick test_string_conversion;
    Alcotest.test_case "static enemy" `Quick test_static_enemy_does_not_move;
    Alcotest.test_case "patrol enemy" `Quick test_patrol_enemy_moves;
    Alcotest.test_case "spawn enemy position" `Quick test_spawn_enemy_position;
    Alcotest.test_case "despawn enemies" `Quick test_despawn_dead;
];
]

  
