open Shovelknight
open Types
open QCheck

let test_object_creation () =
    let gold = Object.create_object (Gold Yellow) 10. 20. in
    let heal = Object.create_object (Heal Green) 5. 5. in
    
    let (x1, y1) = Entity.get_position gold in
    let (x2, y2) = Entity.get_position heal in
    Alcotest.(check (float 0.01)) "gold x" 10. x1;
    Alcotest.(check (float 0.01)) "gold y" 20. y1;
    Alcotest.(check (float 0.01)) "heal x" 5. x2;
    Alcotest.(check (float 0.01)) "heal y" 5. y2;
    
    match gold.entity_type, heal.entity_type with
    | Object { obj_type = Gold Yellow; _ }, Object { obj_type = Heal Green; _ } -> ()
    | _ -> Alcotest.fail "Wrong object types"

let test_object_collision () =
    let player = Generators.gen_player_entity |> Gen.generate1 in
    let obj = Object.create_object (Gold Blue) 0. 0. in
    
    let player_on_obj = { player with position = { x = 0.; y = 0. } } in
    Alcotest.(check bool) "collision" true 
        (Object.check_object_collision obj player_on_obj);
    
    let player_far = { player with position = { x = 10.; y = 10. } } in
    Alcotest.(check bool) "no collision" false
        (Object.check_object_collision obj player_far)


let test_object_effects () =
    let gs = Generators.gen_game_state |> Gen.generate1 in
    let gold_obj = Object.create_object (Gold Red) 0. 0. in
    let heal_obj = Object.create_object (Heal Green) 0. 0. in
    let mana_obj = Object.create_object (Mana ManaJar) 0. 0. in 
    
    let gs_after_gold = Object.apply_object_effect gs gold_obj in
    (match gs_after_gold.player.entity_type with
        | Player p -> Alcotest.(check bool) "gold added" true (p.gold > 0)
        | _ -> Alcotest.fail "Should be player");
    
    let damaged_player = { gs.player with 
        entity_type = match gs.player.entity_type with
        | Player p -> Player { p with current_health = 50 }
        | _ -> failwith "not player"
    } in

    let gs_damaged = { gs with player = damaged_player } in
    let gs_after_heal = Object.apply_object_effect gs_damaged heal_obj in

    let low_mana_player = { gs_after_heal.player with 
        entity_type = match gs_after_heal.player.entity_type with 
        | Player p -> Player {p with current_mana = 10}
        | _ -> failwith "not player"} in 

    let gs_low_mana = {gs_after_heal with player = low_mana_player} in 

    let gs_after_mana = Object.apply_object_effect gs_low_mana mana_obj in 

    (match gs_after_mana.player.entity_type with
        | Player p -> Alcotest.(check bool) "health restored" true (p.current_health > 50);
                      Alcotest.(check bool) "mana restored" true (p.current_mana > 10)
        | _ -> Alcotest.fail "Should be player")


let test_drop_objects () =
    let enemy = Enemy.create_beeto 0. 0. in
    let gs = Generators.gen_game_state |> Gen.generate1 in
    
    let drops = Object.drop_objects gs enemy in
    Alcotest.(check bool) "drops something" true (List.length drops > 0)


let test_update_objects () =
    let falling_obj = Object.create_object ~state:Falling ~vy:1.0 (Gold Blue) 10. 10. in
    let gs = { (Generators.gen_game_state |> Gen.generate1) with
                objects = [falling_obj] } in
    
    let gs' = Object.update_objects gs in
    match gs'.objects with
    | [updated] -> 
        let (_, y) = Entity.get_position updated in
        Alcotest.(check bool) "object fell" true (y > 10.0)
    | _ -> Alcotest.fail "Should have one object"


let test_projectiles () =
    let gs = Generators.gen_game_state |> Gen.generate1 in
    let initial_count = List.length gs.objects in
    
    let gs' = Object.cast_projectile gs in
    Alcotest.(check bool) "projectile added" true 
        (List.length gs'.objects = initial_count + 1);
    
    match List.hd gs'.objects with
    | { entity_type = Object { obj_type = Projectile FireBall; _ }; _ } -> ()
    | _ -> Alcotest.fail "Should be projectile"


let () =
Alcotest.run "Object Tests" [
    ("Creation", [
    Alcotest.test_case "Object creation" `Quick test_object_creation;
    ]);
    ("Collision", [
        Alcotest.test_case "Object collision" `Quick test_object_collision;
    ]);
    ("Effects", [
        Alcotest.test_case "Object effects" `Quick test_object_effects;
    ]);
    ("Drops", [
        Alcotest.test_case "Object drops" `Quick test_drop_objects;
    ]);
    ("Update", [
    Alcotest.test_case "Object updates" `Quick test_update_objects;
    ]);
    ("Projectiles", [
        Alcotest.test_case "Projectile casting" `Quick test_projectiles;
    ]);
]