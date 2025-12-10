open Shovelknight
open Types
open QCheck

let test_player_initialization () =
    let player = Player.initialize_player "MyPlayer" in
    Alcotest.(check string) "player name" "MyPlayer" (Player.get_player_name player);
    match player.entity_type with
    | Player p ->
        Alcotest.(check int) "initial health" 8 p.current_health;
        Alcotest.(check int) "max health" 8 p.max_health
    | _ -> Alcotest.fail "Should be player type"


let test_position_updates () =
    let player = Player.initialize_player "Test" in
    let updated = Player.update_position player 10. 20. in
    let (x, y) = Entity.get_position updated in
    Alcotest.(check (float 0.01)) "new x" 10. x;
    Alcotest.(check (float 0.01)) "new y" 20. y
    
    let test_map_collision () =
    let map = Generators.gen_map in
    let player = Player.initialize_player "Test" |> fun p -> 
        { p with position = { x = 50.; y = 50. } } in
    Alcotest.(check bool) "no collision" false (Player.check_map_collision player map);
    
    let colliding = { player with position = { x = 0.; y = 99. } } in
    Alcotest.(check bool) "collision" true (Player.check_map_collision colliding map)

let test_player_states () =
    let player = Player.initialize_player "Test" in
    let gs = { (Generators.gen_game_state |> Gen.generate1) with player } in
    
    let gs_attacking = Player.update_player_state gs (Attacking,1) in
    Alcotest.(check bool) "state changed" true 
        (Player.get_player_state gs_attacking.player = (Attacking,1));
    
    Alcotest.(check string) "state string" "Attacking,1" 
        (Player.string_of_state (Attacking, 1))

let test_attack_mechanics () =
    let gs = Generators.gen_game_state |> Gen.generate1 in
    let gs_with_cooldown = Player.update_attack_time gs 0.5 in
    
    let cd = Player.get_player_attack_time gs_with_cooldown.player in
    Alcotest.(check (float 0.01)) "cooldown updated" 0.5 cd;
    
    let gs_with_damage = Player.update_player_attack gs 15 in
    match gs_with_damage.player.entity_type with
    | Player p -> Alcotest.(check int) "attack increased" 15 p.attack
    | _ -> Alcotest.fail "Should be player"

let test_platform_interaction () =
    let player = Player.initialize_player "Test" in
    let platform = {
        position = { x = 0.; y = 10. };
        velocity = { vx = 2.; vy = 0. };
        hitbox = Types.Rectangular { width = 10.; height = 1. };
        entity_type = MovingPlatform {skin=Solid Grass ; movement=(2.,2.)};
        state = (Idle,1)
      } in
    
    let player_on_platform = { player with position = { x = 0.; y = 8. } } in
    let moved = Player.move_with_platform player_on_platform [platform] 1.0 in
    Alcotest.(check (float 0.01)) "moved with platform" 2. moved.position.x;
    
    Alcotest.(check bool) "on platform" true
        (Player.check_platform_collision player_on_platform [platform])

let test_ground_detection () =
    let map = Generators.gen_map in
    let player = Player.initialize_player "Test" in
    let grounded = { player with position = { x = 50.; y = 96. } } in
    Alcotest.(check bool) "on ground" true 
        (Player.is_on_ground grounded map [])


    let () =
    Alcotest.run "Player Tests" [
      ("Initialization", [
        Alcotest.test_case "Player creation" `Quick test_player_initialization;
      ]);
      ("Position", [
        Alcotest.test_case "Position update" `Quick test_position_updates;
        Alcotest.test_case "Map collision" `Quick test_map_collision;
      ]);
      ("States", [
        Alcotest.test_case "State management" `Quick test_player_states;
      ]);
      ("Platforms", [
        Alcotest.test_case "Platform movement" `Quick test_platform_interaction;
      ]);
      ("Combat", [
        Alcotest.test_case "Attack mechanics" `Quick test_attack_mechanics;
      ]);
      ("Physics", [
        Alcotest.test_case "Ground detection" `Quick test_ground_detection;
      ]);
    ]