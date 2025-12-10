open Yojson.Basic.Util

open Types
open Object
open Enemy
open Core.Camera
open Player

type entity = {
  skin : string;
  pos : float * float;
  movement : (float*float) option;
}

type level = {
  name : string;
  boss : string;
  music : string;
  width : int;
  height : int;
  layer : int list;
  enemies : entity list;
  objects : entity list;
  moving_platforms : entity list;
}

let level_of_string s = 
  match s with 
  | "plains_of_passage" -> Plains_of_passage 
  | "lost_city" -> Lost_city
  | _ -> failwith "LEVELHANDLER le niveau n'exsiste pas" 

let parse_entity json =
  let skin = json |> member "skin" |> to_string in
  let pos = json |> member "position" |> to_list |> filter_float |> function
    | [x; y] -> (x, y)
    | _ -> failwith "Invalid position format"
  in
  let movement = match json |> member "movement" with
    | `Null -> None
    | m ->
      (match filter_float (to_list m) with
      | [dx; dy] -> Some (dx, dy)
      | _ -> failwith "Invalid movement format")
  in
  { skin; pos; movement }
  

let parse_level file_path : level =
  if Sys.file_exists file_path |> not then failwith "Erreur fichier json introuvable" else
  let json = Yojson.Basic.from_file file_path in
  let name = json |> member "name" |> to_string in 
  let boss = json |> member "boss" |> to_string in 
  let music = json |> member "music" |> to_string in 
  let width = json |> member "width" |> to_int in
  let height = json |> member "height" |> to_int in
  let layer = json |> member "layer" |> to_list |> filter_int in
  let enemies = json |> member "enemies" |> to_list |> List.map parse_entity in
  let objects = json |> member "objects" |> to_list |> List.map parse_entity in
  let moving_platforms = json |> member "moving_platforms" |> to_list |> List.map parse_entity in 
  { name; boss; music; width; height; layer; enemies; objects; moving_platforms}

let block_of_int int = 
  match int with 
  | 357 -> Solid Dirt 
  | 361 -> Solid Grass 
  | 511 -> Solid Grass 
  | 397 -> Hostile Spikes
  | 444 -> Hostile Lava
  | 428 -> Interactive Lever
  | 0 -> Empty
  | 607 -> Empty
  | 410 -> Solid BlackStone
  | 433 -> Solid Rock
  | 423 -> Interactive Ladder
  | 356 -> Interactive Ladder
  | _ -> failwith ("LEVELHANDLER block n existe pas encore" ^ (string_of_int int))

let map_of_level level = 
  let h = level.height in 
  let w = level.width in 
  let layer = level.layer in 
  let map = Array.make_matrix h w Empty in 
  List.iteri (fun i block -> 
    let x = i mod w in 
    let y = i / w in 
    map.(y).(x) <- block_of_int block) layer; 
    map

let object_of_gameobject g  = 
  let skin = g.skin in 
  let (x,y) = g.pos in 
  create_object (object_of_string skin) x y


let enemy_of_record r = 
  let skin = r.skin in 
  let (x,y) = r.pos in 
  match (enemy_of_string skin) with 
  | Beeto -> create_beeto x y 
  | Blorb -> create_blorb x y
  | Boneclang -> create_boneclang x y 
  | Dozedrake -> create_dozedrake x y
  | Firedrake -> create_firedrake x y
  | Goldarmor -> create_goldarmor x y
  | Hoppicles -> create_hoppicles x y
  | Moller -> create_moller x y

let moving_platform_of_record r = 
  let skin = r.skin in 
  let (x,y) = r.pos in 
  let block = skin |> int_of_string |> block_of_int in 
  let movement = 
    (match r.movement with 
    | Some d -> d 
    | None -> failwith "LEVELHANDLER la plateforme doit avoir une distance") in 
  {
    entity_type = MovingPlatform {skin = block ; movement = movement};
    position = { x = x; y = y };
    velocity = { vx = 1.0; vy = 0.0 };
    hitbox = Rectangular { width = 3.0; height = 1.0 };
    state = (Idle, 0);
  }

let gamestate_of_level name level config : game_state = 
  let map = map_of_level level in 
  let camera = initialize_camera map config in 
  let player = initialize_player name in 
  let player = spawn_player player map 2. in 
  let name = level_of_string level.name in 
  let boss = enemy_of_string level.boss in 
  let music = level.music in 
  let enemies = List.map enemy_of_record level.enemies in
  let objects = List.map object_of_gameobject level.objects in 
  let moving_platforms = List.map moving_platform_of_record level.moving_platforms in 
  
  { camera ; map ; player ; name; boss; music; enemies ; moving_platforms ; objects}

let create_level name path config =
  let level = parse_level path in 
  gamestate_of_level name level config

