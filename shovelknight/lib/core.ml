module Config = struct
    type t = {
      screen_height : int;
      screen_width : int;
      rows : int;
      cols : int;
      block_height : float;
      block_width : float;
    }
  
    let initialize height width = {
      screen_height = height;
      screen_width = width;
      rows = 25;
      cols = 13;
      block_height = ceil (float_of_int height /. 13.);
      block_width = ceil (float_of_int width /. 25.);
    }
  
    let print cfg =
      Printf.printf "Configuration du jeu :\n";
      Printf.printf "  Dimensions de l'écran : %d x %d\n" cfg.screen_width cfg.screen_height;
      Printf.printf "  Nombre de rangées : %d\n" cfg.rows;
      Printf.printf "  Nombre de colonnes : %d\n" cfg.cols;
      Printf.printf "  Taille d'un bloc : %.2f x %.2f\n" cfg.block_width cfg.block_height
  end
  
  module Collision = struct
    open Types
  
    let rectangles_collide pos1 (w1, h1) pos2 (w2, h2) =
      not (
        pos1.x +. w1 < pos2.x ||
        pos2.x +. w2 < pos1.x ||
        pos1.y +. h1 < pos2.y ||
        pos2.y +. h2 < pos1.y
      )
  
    let get_colliding_enemies game_state =
      let player_rect =
        match game_state.player.hitbox with
        | Rectangular { width; height } -> (game_state.player.position, (width, height))
        | _ -> failwith "La hitbox du joueur doit être rectangulaire"
      in
      List.filter (fun enemy ->
        match enemy.hitbox with
        | Rectangular { width; height } ->
          rectangles_collide (fst player_rect) (snd player_rect) enemy.position (width, height)
        | _ -> false
      ) game_state.enemies
  end
  
  module Hitbox = struct
    open Types
    let make_rectangular w h = Rectangular { width = w; height = h }
  end

  module Map = struct 
    open Types
    let string_of_block = function
      | Solid Grass -> "G"
      | Solid Dirt -> "D"
      | Solid BlackStone -> "B"
      | Solid Rock -> "R"
      | Hostile Spikes -> "^"
      | _ -> "."

    let print_map map =
      Array.iter (fun row ->
        Array.iter (fun block -> print_string (string_of_block block)) row;
        print_endline ""
      ) map

  
    let find_ground_y map column =
      (* On parcourt la colonne column *)
      let column_blocks = Array.map (fun row -> row.(column)) map in
      let rec find index =
        if index >= (column_blocks |> Array.length) then None
        else match column_blocks.(index) with
          | Solid _ -> Some index
          | _ -> find (index + 1)
      in
      find 0
    end


module Camera = struct 
  open Types
  open Map
  open Config

let initialize_camera map config = 
    match (find_ground_y map 0) with 
    | Some y -> {cx = 0. ; cy= if (Array.length map) - y < 2 then (float_of_int y) -. 12. else (float_of_int y) -. 11.}
    | None -> {cx = 0. ; cy = 13. *. config.block_height} (* Jeter une erreur est mieux *)
end