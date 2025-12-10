(* game.ml *)
open Types
open Player
open Core.Camera
open Entity
open Core.Map

module GSMonad = struct 
  type 'a t = game_state -> 'a * game_state

  let return x = fun s -> (x,s)

  let bind m f = fun s -> 
    let (x,s') = m s in 
    f x s' 

  let get = fun s -> (s,s)

  let put new_gs = fun _ -> ((), new_gs)

  let (let*) = bind

  let apply f = fun gs -> let new_gs = f gs in ((),new_gs)

end

let reset_gamestate gs config = 
  let new_player = reset_player gs.player gs.map in 
  {gs with player = new_player ; camera = initialize_camera gs.map config}

let print_gamestate gamestate =
  Printf.printf "Camera: (%f,%f)\n" gamestate.camera.cx gamestate.camera.cy;
  print_map gamestate.map;
  print_entity gamestate.player;
  print_entities gamestate.enemies;
  print_entities gamestate.objects