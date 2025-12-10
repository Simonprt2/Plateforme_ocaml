open QCheck 
open Shovelknight
open Types 
open Player
open Core
open Generators
open Draw

let clamp v min_val max_val =
    max min_val (min v max_val)

let test_clamp =
    Test.make
      ~name:"clamp returns values within bounds"
      (triple float float float)
      (fun (v, min_val, max_val) ->
        let min_val, max_val = if min_val > max_val then max_val, min_val else min_val, max_val in
        let result = clamp v min_val max_val in
        result >= min_val && result <= max_val)

let test_check_map_collision =
    Alcotest.test_case "check_map_collision prevents crossing solid blocks" `Quick (fun () ->
        let map = [| [| Solid Grass; Empty |] |] in
        let entity =  initialize_player "name" in
        let result = check_map_collision entity map in
        Alcotest.(check bool) "Collision detected" true result)


let test_all_colliding_enemies_do_collide =
    let open QCheck in
    Test.make 
        ~name:"All enemies returned actually collide"
        (make gen_game_state)
        (fun gs ->
        let collided = Collision.get_colliding_enemies gs in
        List.for_all (fun enemy ->
            match (gs.player.hitbox, enemy.hitbox) with
            | Rectangular { width = pw; height = ph },
            Rectangular { width = ew; height = eh } ->
                Collision.rectangles_collide
                gs.player.position (pw, ph)
                enemy.position (ew, eh)
            | _ -> true
        ) collided)


let test_world_to_screen_center () =
    let camera = { cx = 0.0; cy = 0.0 } in
    let config = Config.initialize 757 1536 in
    let pos = { x = 1.0; y = 1.0 } in
    let (sx, sy) = world_to_screen camera pos config in
    Alcotest.(check (float 0.01)) "sx" config.block_width sx;
    Alcotest.(check (float 0.01)) "sy" config.block_height sy
          
          


let test_get_map_offsets_origin () =
    let camera = { cx = 0. ; cy = 0. } in
    let (tile_x, tile_y, offset_x, offset_y) = get_map_offsets camera in
    Alcotest.(check int) "tile_x" 0 tile_x;
    Alcotest.(check int) "tile_y" 0 tile_y;
    Alcotest.(check (float 0.0001)) "offset_x" 0.0 offset_x;
    Alcotest.(check (float 0.0001)) "offset_y" 0.0 offset_y
          
          


let () =
let suite = List.map QCheck_alcotest.to_alcotest 
    [ 
        test_clamp;
    ] in 
    Alcotest.run "Shovelknight tests" 
    [
        "clamp", suite;
        "check_map_collision", [test_check_map_collision];
        "get_colliding_enemies", [QCheck_alcotest.to_alcotest test_all_colliding_enemies_do_collide];
        "get_map_offsets", [ Alcotest.test_case "origin" `Quick test_get_map_offsets_origin ];
        "world_to_screen", [ Alcotest.test_case "position in function of block_size" `Quick test_world_to_screen_center ];
    ]; 