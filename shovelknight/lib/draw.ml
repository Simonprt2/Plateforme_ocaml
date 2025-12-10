open Types
open Core.Config
open Texture
open Raylib
open Player
open Enemy

let get_map_offsets camera =
    let start_x = int_of_float camera.cx in
    let start_y = int_of_float camera.cy in
    let offset_x = camera.cx -. float_of_int start_x in
    let offset_y = camera.cy -. float_of_int start_y in
    (start_x, start_y, offset_x, offset_y)

let world_to_screen camera (pos : position) config =
    let bw = config.block_width and bh = config.block_height in
    ((pos.x -. camera.cx) *. bw, (pos.y -. camera.cy) *. bh)

let draw_map camera map config =
    let bw = config.block_width and bh = config.block_height in
    let (start_x, start_y, offset_x, offset_y) = get_map_offsets camera in
    let end_x = min (start_x + 25) (Array.length map.(0) - 1) in
    let end_y = min (start_y + 13) (Array.length map - 1) in
    for y = start_y to end_y do
      for x = start_x to end_x do
        let block = map.(y).(x) in
        let screen_x = (float_of_int (x - start_x) -. offset_x) *. bw in
        let screen_y = (float_of_int (y - start_y) -. offset_y) *. bh in
        if block <> Empty then draw_block block screen_x screen_y config
      done
    done


let render_player camera player config =
    let (screen_x, screen_y) = world_to_screen camera player.position config in
    let vx = player.velocity.vx in 
    draw_player player screen_x screen_y vx player.hitbox config


let draw_camera_info camera cfg =
    let text = Printf.sprintf "Camera: (%.2f, %.2f)" camera.cx camera.cy in
    draw_text text (cfg.screen_width - 500) 10 20 Color.black

let draw_entity_infos player cfg =
match player.entity_type with
| Player p ->
    let x = cfg.screen_width - 500 in 
    let health_text = Printf.sprintf "HEALTH : %d / %d" p.current_health p.max_health in
    let mana_text = Printf.sprintf "MANA : %d / %d" p.current_mana p.max_mana in
    let gold_text = Printf.sprintf "GOLD : %d" p.gold in
    let state_text = Printf.sprintf "STATE : %s" (string_of_state player.state) in 
    let timer_text = Printf.sprintf "TIMER : %f" p.attack_time in 
    let pos_text = Printf.sprintf "POSITION : %f / %f" player.position.x player.position.y in 
    let v_text = Printf.sprintf "VELOCITY : %f / %f" player.velocity.vx player.velocity.vy in 
    draw_text health_text x 30 20 Color.black;
    draw_text mana_text x 50 20 Color.black;
    draw_text gold_text x 70 20 Color.black;
    draw_text state_text x 90 20 Color.black;
    draw_text timer_text x 110 20 Color.black;
    draw_text pos_text x 150 20 Color.black;
    draw_text v_text x 170 20 Color.black;
| Enemy e -> 
    let enemy_text = Printf.sprintf "%s" (string_of_enemy e.skin) in 
    let health_text = Printf.sprintf "HEALTH : %d " e.current_health in 
    let timer = Printf.sprintf "TIMER : %f/%f" e.attack_time e.cooldown in 
    let state_text = Printf.sprintf "STATE : %s" (string_of_state player.state) in
    let vel_text = Printf.sprintf "VELOCITY : %f, %f" player.velocity.vx player.velocity.vy in 
    draw_text health_text 500 0 20 Color.red;
    draw_text timer 500 20 20 Color.red;
    draw_text enemy_text 500 40 20 Color.red;
    draw_text state_text 500 60 20 Color.red;
    draw_text vel_text 500 80 20 Color.red;
| _ -> ()



let draw_objects camera objects config =
    List.iter (fun obj ->
        let (screen_x, screen_y) = world_to_screen camera obj.position config in
        draw_object obj screen_x screen_y config
    ) objects

let draw_moving_platforms camera (mps : game_entity list) config = 
    List.iter (fun mp -> 
        let (screen_x, screen_y) = world_to_screen camera mp.position config in 
        draw_moving_platform mp screen_x screen_y config
    ) mps

let draw_enemies gs config = 
    List.iter (fun enemy ->
        let (screen_x, screen_y) = world_to_screen gs.camera enemy.position config in
        draw_enemy enemy screen_x screen_y gs config
    ) gs.enemies
    

let render gs config =
    draw_map gs.camera gs.map config;
    render_player gs.camera gs.player config;
    draw_objects gs.camera gs.objects config;
    draw_enemies gs config;
    draw_moving_platforms gs.camera gs.moving_platforms config
