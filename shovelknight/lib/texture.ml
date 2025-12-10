open Raylib
open Types
open Core.Config
open State

type ('a, 'b) sprite = ('a * 'b) list

type 'a sprites = {
  texture: Raylib.Texture2D.t Lazy.t;
  textures: ('a, Rectangle.t) sprite;
}

let create_sprites texture_path rects = {
  texture = lazy (load_texture texture_path);
  textures = rects
}

let sprites_path = "sprites/"
let enemies_path = sprites_path ^ "enemies/"
let objects_path = sprites_path ^ "objects/"
let levels_path = sprites_path ^ "core/"

let knight_path = sprites_path ^ "knight/"

let init_rect_with_idx i j = 
  Rectangle.create (16. *. j) (16. *. i) 16. 16.

let block_sprites =
  create_sprites (levels_path ^ "atlas_map.png") [
    (Grass, init_rect_with_idx 14. 10.);
    (Dirt, init_rect_with_idx 14. 6.);
    (Spikes, init_rect_with_idx 15. 22.);
    (Lever, init_rect_with_idx 17. 27.);
    (Rock, init_rect_with_idx 17. 33.);
    (Lava, init_rect_with_idx 17. 43.);
    (BlackStone, init_rect_with_idx 15. 43.);
    (Ladder, init_rect_with_idx 14. 5.);
  ]

let find_sprite key sprites =
  try List.assoc key sprites
  with Not_found -> failwith ("Sprite not found")

let knight_sprites = 
  create_sprites (knight_path ^ "knight.png")
  [
    ((Idle,1),(Rectangle.create 2. 2. 34. 31.));
    ((Running, 1),(Rectangle.create 2. 104. 40. 34.));
    ((Running, 2),(Rectangle.create 44. 104. 40. 34.));
    ((Running, 3),(Rectangle.create 86. 104. 40. 34.));
    ((Running, 4),(Rectangle.create 128. 104. 40. 34.));
    ((Running, 5),(Rectangle.create 170. 104. 40. 34.));
    ((Running, 6),(Rectangle.create 212. 104. 40. 34.));
  
    ((Attacking,1),(Rectangle.create 2. 575. 31. 32.));
    ((Attacking,2),(Rectangle.create 58. 575. 53. 32.));
    ((Attacking,3),(Rectangle.create 121. 575. 30. 32.));
    ((Attacking,4),(Rectangle.create 171. 575. 31. 32.));
  
    ((Jumping,1),(Rectangle.create 2. 175. 31. 33.));
    ((Falling,1),(Rectangle.create 2. 211. 33. 33.));

    ((Climbing,1),(Rectangle.create 2. 475. 25. 32.));
    ((Climbing,2),(Rectangle.create 29. 475. 25. 32.));
  ]

let object_sprites = 
  create_sprites (objects_path ^ "atlas_item.png")
  [
    ((Gray),(Rectangle.create 2. 2. 21. 16.));
    ((Blue),(Rectangle.create 25. 2. 21. 16.));
    ((Green),(Rectangle.create 48. 2. 21. 16.));
    ((Yellow),(Rectangle.create 71. 2. 21. 16.));
    ((Red),(Rectangle.create 94. 2. 21. 16.));
    ((Magenta),(Rectangle.create 117. 2. 21. 16.));
    (Chicken,(Rectangle.create 142. 2. 27. 18.));
    (ManaBottle,(Rectangle.create 173. 2. 9. 11.));
    (FireBall, (Rectangle.create 2. 2. 21. 16.))
  ]

let enemy_sprites = 
  create_sprites (enemies_path ^ "atlas_enemy.png")
  [
    ((Boneclang, Idle, 1),(Rectangle.create 2. 2. 32. 30.)); 
    ((Boneclang, Running, 1),(Rectangle.create 2. 35. 32. 30.)); 
    ((Boneclang, Running, 2),(Rectangle.create 36. 35. 32. 30.)); 
    ((Boneclang, Running, 3),(Rectangle.create 70. 35. 32. 30.)); 
    ((Boneclang, Running, 4),(Rectangle.create 104. 35. 32. 30.)); 
    ((Boneclang, Attacking, 1),(Rectangle.create 2. 177. 32. 30.));
    ((Boneclang, Attacking, 2),(Rectangle.create 52. 177. 32. 30.));
  
    ((Firedrake, Idle, 1),(Rectangle.create 172. 2. 40. 35.));
    ((Firedrake, Attacking, 1),(Rectangle.create 214. 2. 40. 35.));
    ((Firedrake, Attacking, 2),(Rectangle.create 256. 2. 40. 35.));
    ((Firedrake, Attacking, 3),(Rectangle.create 298. 2. 40. 35.));
    ((Firedrake, Attacking, 4),(Rectangle.create 340. 2. 40. 35.));
    ((Firedrake, Running, 1),(Rectangle.create 172. 2. 40. 35.));
    ((Firedrake, Running, 2),(Rectangle.create 172. 2. 40. 35.));
    ((Firedrake, Running, 3),(Rectangle.create 172. 2. 40. 35.));
    ((Firedrake, Running, 4),(Rectangle.create 172. 2. 40. 35.));
    ((Firedrake, Running, 5),(Rectangle.create 172. 2. 40. 35.));
    ((Firedrake, Running, 6),(Rectangle.create 172. 2. 40. 35.));
  
  
    ((Beeto, Idle, 1),(Rectangle.create 427. 2. 25. 15.));
    ((Beeto, Attacking, 1),(Rectangle.create 427. 2. 25. 15.));
    ((Blorb, Idle, 1),(Rectangle.create 562. 2. 20. 11.));
    ((Blorb, Attacking, 1),(Rectangle.create 562. 2. 20. 11.));
    
    ((Dozedrake, Idle, 1),(Rectangle.create 630. 2. 140. 78.));
    ((Dozedrake, Idle, 2),(Rectangle.create 800. 2. 140. 78.));
    ((Dozedrake, Idle, 3),(Rectangle.create 971. 2. 140. 78.));
    ((Dozedrake, Idle, 4),(Rectangle.create 1141. 2. 140. 78.));
    ((Dozedrake, Idle, 5),(Rectangle.create 1312. 2. 140. 78.));
    ((Dozedrake, Idle, 6),(Rectangle.create 1482. 2. 140. 78.));
    ((Dozedrake, Idle, 7),(Rectangle.create 1653. 2. 140. 78.));
    ((Dozedrake, Idle, 8),(Rectangle.create 1823. 2. 140. 78.));
    ((Dozedrake, Idle, 9),(Rectangle.create 1994. 2. 140. 78.));
    ((Dozedrake, Idle, 10),(Rectangle.create 2164. 2. 140. 78.));
    ((Dozedrake, Idle, 11),(Rectangle.create 2335. 2. 140. 78.));
  
    ((Dozedrake, Attacking, 1),(Rectangle.create 630. 170. 140. 74.));
    ((Dozedrake, Attacking, 2),(Rectangle.create 630. 249. 140. 74.));
    ((Dozedrake, Attacking, 3),(Rectangle.create 630. 90. 140. 74.));
  
    ((Dozedrake, Running, 6),(Rectangle.create 630. 414. 140. 74.));
    ((Dozedrake, Running, 5),(Rectangle.create 798. 414. 140. 74.));
    ((Dozedrake, Running, 4),(Rectangle.create 965. 414. 140. 74.));
    ((Dozedrake, Running, 3),(Rectangle.create 1133. 414. 140. 74.));
    ((Dozedrake, Running, 2),(Rectangle.create 1301. 414. 140. 74.));
    ((Dozedrake, Running, 1),(Rectangle.create 1468. 414. 140. 74.));

    (Goldarmor, Idle, 1),(Rectangle.create 2800. 2. 31. 35.);
    (Goldarmor, Attacking, 1),(Rectangle.create 2800. 82. 26. 35.);
    (Goldarmor, Attacking, 2),(Rectangle.create 2800. 119. 35. 35.);
    (Goldarmor, Running, 1),(Rectangle.create 2800. 42. 31. 35.);
    (Goldarmor, Running, 2),(Rectangle.create 2833. 42. 31. 35.);
    (Goldarmor, Running, 3),(Rectangle.create 2866. 42. 31. 35.);
    (Goldarmor, Running, 4),(Rectangle.create 2899. 42. 31. 35.);
  
    (Hoppicles, Idle, 1),(Rectangle.create 2678. 2. 28. 37.);
    (Hoppicles, Attacking, 1),(Rectangle.create 2688. 132. 33. 40.);
    (Hoppicles, Attacking, 2),(Rectangle.create 2735. 132. 46. 40.);
    (Hoppicles, Running, 1),(Rectangle.create 2678. 263. 24. 40.);
    (Hoppicles, Running, 2),(Rectangle.create 2704. 263. 24. 40.);
  
    (Moller, Idle, 1),(Rectangle.create 2934. 2. 36. 15.);
    (Moller, Attacking, 1),(Rectangle.create 2934. 2. 36. 15.);
    (Moller, Attacking, 2),(Rectangle.create 2934. 27. 40. 17.);
    (Moller, Running, 1),(Rectangle.create 2934. 2. 36. 15.);
    (Moller, Running, 2),(Rectangle.create 2972. 2. 36. 15.);
    (Moller, Running, 3),(Rectangle.create 3010. 2. 36. 15.);
    (Moller, Running, 4),(Rectangle.create 3048. 2. 36. 15.)
  
  ]


let block_skin_to_string = function
| Grass -> "Grass"
| Dirt -> "Dirt"
| Bush -> "Bush"
| Ladder -> "Ladder"
| Cloche -> "Cloche"
| Chest -> "Chest"
| BreakableDirt -> "BreakableDirt"
| Checkpoint -> "Checkpoint"
| Spikes -> "Spikes"
| BreakableGrass -> "BreakableGrass"
| Rock -> "Rock"
| BlackStone -> "BlackStone"
| Lava -> "Lava"
| Lever -> "Lever"

let get_texture sprites = Lazy.force sprites.texture

let draw_block block bx by config =
  let block_skin = match block with
    | Solid skin -> skin
    | Hostile skin -> skin
    | Breakable (skin, _) -> skin
    | Interactive skin -> skin
    | DecorativeFront skin -> skin
    | DecorativeBack skin -> skin
    | Empty -> failwith "Cannot draw an empty block"
  in
  try
    let source_rect = find_sprite block_skin block_sprites.textures in
    let dest_rect = Rectangle.create (bx) (by) config.block_width config.block_height in
    draw_texture_pro (get_texture block_sprites) source_rect dest_rect (Vector2.create 0.0 0.0) 0.0 Color.white
  with Not_found ->
    failwith "Le bloc n'existe pas"

let draw_bar x y bar_width bar_height ratio background_color fill_color =
  draw_rectangle (int_of_float x) (int_of_float y)
                  (int_of_float bar_width) (int_of_float bar_height) background_color;

  let fill_width = bar_width *. ratio in
  draw_rectangle (int_of_float x) (int_of_float y)
                  (int_of_float fill_width) (int_of_float bar_height) fill_color;

  draw_rectangle_lines (int_of_float (x -. 1.)) (int_of_float y)
                        (int_of_float bar_width) (int_of_float bar_height) Color.black

  

let draw_enemy enemy ex ey gs config =
  let player = gs.player in 
  let (hw, hh) = Entity.get_hitbox_dims enemy.hitbox in
  match enemy.entity_type with
  | Enemy e ->
    (* Logique de base de retournement de sprites pour les mouvements *)
    let base_w_factor = 
      match e.enemy_movement with
      | Patrol _ -> 
          if enemy.velocity.vx < 0. then -1. else 1. 
      | _ -> 
          if player.position.x < enemy.position.x then -1. else 1.
    in
    
    (* Vérifie si l'ennemi est en train d'attaquer pour le retournement sur les attaques*)
    let (es, _) = enemy.state in
    let w_factor = 
      if es = Attacking then
        if player.position.x < enemy.position.x then -1. else 1.
      else
        base_w_factor
    in
    
    let (es, k) = get_sprite_index enemy in 
    let source_rect = find_sprite (e.skin, es, k) enemy_sprites.textures in
    let new_rect = Rectangle.create 
      (Rectangle.x source_rect) 
      (Rectangle.y source_rect) 
      (Rectangle.width source_rect *. w_factor) 
      (Rectangle.height source_rect) 
    in 
    
    let dest_rect = Rectangle.create ex ey (hw *. config.block_width) (hh *. config.block_height) in
    draw_texture_pro (get_texture enemy_sprites) new_rect dest_rect (Vector2.create 0.0 0.0) 0.0 Color.white;

    let health_ratio = float_of_int e.current_health /. float_of_int e.max_health in
    draw_bar ex (ey -. 12.0) (hw *. config.block_width) 10. health_ratio Color.darkgray Color.green;
    
    if (Entity.is_boss enemy gs) && (Enemy.is_enemy_visible enemy gs.camera config) then 
      let mid = config.screen_width / 2 in 
      draw_bar (float_of_int (mid/2)) 100. (float_of_int mid) 20. health_ratio Color.darkblue Color.red;
      draw_text "Dozedrake" (mid/2) 80 20 Color.black;

  | _ -> ()


  let draw_player_profile_square player =
    let tex = get_texture knight_sprites in
    let full_src = find_sprite (Idle,1) knight_sprites.textures in
  
    let head_width = 20. in
    let head_height = 20. in
    let offset_x = Rectangle.x full_src +. 6. in 
    let offset_y = Rectangle.y full_src +. 2. in
  
    let src = Rectangle.create offset_x offset_y head_width head_height in
  
    let dest_size = 64. in
    let x = 20. in
    let y = 20. in
  
    let dest = Rectangle.create x y dest_size dest_size in
    let origin = Vector2.create 0.0 0.0 in
  
    draw_rectangle_lines (int_of_float x - 1) (int_of_float y - 1)
                         (int_of_float dest_size + 2) (int_of_float dest_size + 2) Color.black;
    draw_texture_pro tex src dest origin 0.0 Color.white;
  
    match player.entity_type with
    | Player p ->

      let text_size = 20 in
      let bar_width = 200. in
      let bar_height = 20. in
      let bar_x = x +. dest_size +. 1. in
      let bar_y = y +. (float_of_int text_size) in

      draw_text p.name (int_of_float bar_x + 2) (int_of_float y) text_size Color.black;

      let health_ratio = float_of_int p.current_health /. float_of_int p.max_health in
      draw_bar bar_x bar_y bar_width bar_height health_ratio Color.darkgray Color.red;

      let mana_ratio = float_of_int p.current_mana /. float_of_int p.max_mana in
      draw_bar bar_x (bar_y +. bar_height) bar_width 10. mana_ratio Color.darkgray Color.blue;

      draw_text ("GOLD : " ^ string_of_int p.gold) (bar_x |> int_of_float |> (+) 2) (bar_y |> int_of_float |> (+) 40 ) 20 Color.black;

    | _ -> ()
  
      

  
let draw_player player px py vx hitbox config = 
  let state = get_sprite_index player in 
  let w_factor = if vx < 0. then -1. else 1. in 
  let (hw,hh) = Entity.get_hitbox_dims hitbox in 
  let source_rect = find_sprite state knight_sprites.textures in 
  let new_rect = Rectangle.create (Rectangle.x source_rect) (Rectangle.y source_rect) (Rectangle.width source_rect *. w_factor) (Rectangle.height source_rect) in 
  let dest_rect = Rectangle.create (px) py (hw *. config.block_width) (hh *. config.block_height) in 
  draw_texture_pro (get_texture knight_sprites) new_rect dest_rect (Vector2.create 0.0 0.0) 0.0 Color.white;
  draw_player_profile_square player


let draw_object obj bx by config = 
  let obj_skin = match obj.entity_type with 
    | Object o -> (match o.obj_type with 
      | Gold t -> t
      | Heal f -> f
      | Mana m -> m
      | Projectile p -> p)
    | _ -> failwith "impossible"
  in
  let source_rect = find_sprite obj_skin object_sprites.textures in 
  let dest_rect = Rectangle.create bx by config.block_width config.block_height in 
  draw_texture_pro (get_texture object_sprites) source_rect dest_rect (Vector2.create 0.0 0.0) 0.0 Color.white

let draw_moving_platform mp bx by config =
  let (hw, hh) = Entity.get_hitbox_dims mp.hitbox in
  let bw = config.block_width in
  let bh = config.block_height in
  match mp.entity_type with
  | MovingPlatform m ->
      let block = m.skin in
      for i = 0 to int_of_float (hw -. 0.001) do
        for j = 0 to int_of_float (hh -. 0.001) do
          let x = bx +. (float_of_int i *. bw) in
          let y = by +. (float_of_int j *. bh) in
          draw_block block x y config
        done
      done
  | _ -> ()
  

let level_to_path = function 
| Plains_of_passage -> "level_one.json"
| Lost_city -> "level_two.json"


let draw_background level config = 
  let path = levels_path ^ (level_to_path level) in 
  let sprite_size = 16 in
  let columns = 24 in
  let rows = 3 in
  for y = 0 to rows - 1 do
    for x = 0 to columns - 1 do
      let x = (float_of_int x *. config.block_width) |> int_of_float in 
      let y = (float_of_int y *. config.block_height) |> int_of_float in 
      let source_rect = Rectangle.create
        (float_of_int (x * sprite_size))
        (float_of_int (y * sprite_size))
        (float_of_int sprite_size)
        (float_of_int sprite_size) in
      let dest_x = float_of_int (x * sprite_size) in
      let dest_y = float_of_int (y * sprite_size) in
      let dest_rect = Rectangle.create dest_x dest_y
        (float_of_int sprite_size) (float_of_int sprite_size) in
      let origin = Vector2.create 0. 0. in
      draw_texture_pro (load_texture path) source_rect dest_rect origin 0. Color.white
    done
  done