type position = {x:float ; y:float}
type velocity = {vx:float ; vy:float}
type camera = {cx:float ; cy:float}

type obj_skin = 
| Gray | Blue | Green | Yellow | Red | Magenta
| Chicken | Sushi
| ManaBottle | ManaJar
| FireBall

type hitbox =
    | Rectangular of { width: float; height: float }
    | Circular of { radius: float }
    | Polygonal of (float * float) list

type entity_state =
    | Idle           (* En repos *)
    | Running        (* En train de courir *)
    | Jumping        (* En train de sauter *)
    | Falling        (* En train de tomber *)
    | Attacking      (* Attaque standard *)
    | Climbing       (* Monter l'echelle *)
    | Throwed        (* Lance un projectile *)

type armor_type = 
    | StalwartPlate (* bleu *)
    | FinalGuard (* rouge *)
    | ConjurersCost (* violet *)
    | DynamoMail (* gris *)
    | MailOfMomentum (* noir *)
    | OrnatePlate (* doré *)

type relic =
    | FlareWand (* tire des boules de feu *)       
    | PhaseLocket (* INVINCIBILITE *) 
    | DustKnuckles (* dash *)
    | ThrowingAnchor (* fait spawn une ancre *)
    | MobileGear (* traverse les pits et spikes et tue les petits mobs *)
    | FishingRod (* Permet d avoir une recompense en lancant dans un fossé *)
    | ChaosSphere (* Lance une boule verte qui fait des dmg et qui rebondit *)
    | PropellerDagger (* permet de voler pendant un instant *)
    | WarHorn (* Fait un AOE *)
    | AlchemyCoin  (* Roll une piece pour du gold (RNG)*)

type attack_type =
    | Melee of int
    | Range of int*float

type enemy_skin = 
    | Beeto 
    | Blorb 
    | Boneclang
    | Dozedrake
    | Firedrake
    | Goldarmor
    | Hoppicles
    | Moller

type enemy_movement =
    | Static
    | Patrol of float*float
    | Chase
    | StaticChase of bool

type block_skin = 
    | Grass
    | Dirt 
    | Bush 
    | Ladder 
    | Cloche 
    | Chest 
    | BreakableDirt 
    | Checkpoint
    | Spikes 
    | BreakableGrass
    | Rock
    | BlackStone
    | Lava
    | Lever


type block =
    | Solid of block_skin
    | Hostile of block_skin
    | Breakable of block_skin * bool
    | Empty
    | Interactive of block_skin
    | DecorativeFront of block_skin
    | DecorativeBack of block_skin

type object_type =
    | Heal of obj_skin
    | Gold of obj_skin
    | Mana of obj_skin
    | Projectile of obj_skin

type state = entity_state * int

type entity_type =
| Player of {
    name: string;
    armor: armor_type;
    attack: int;
    spells: relic list;
    max_mana: int;
    max_health: int;
    current_mana: int;
    current_health: int;
    gold: int;
    attack_time: float;
    }
| Enemy of {
    skin: enemy_skin;
    attack_type: attack_type;
    enemy_movement: enemy_movement;
    current_health: int;
    max_health: int;
    attack_time : float;
    cooldown : float;
    }
| MovingPlatform of {
    skin: block;
    movement: float*float;
    }
| Object of {
    obj_type: object_type;
    collected: bool;
}
  
type game_entity = {
    entity_type: entity_type;
    position: position;
    velocity: velocity;
    hitbox: hitbox;
    state: state
}

type level_name = Plains_of_passage | Lost_city

type map = block array array

type game_state = 
{   
    camera: camera;
    map: map;
    player: game_entity;
    name: level_name;
    boss : enemy_skin;
    music : string;
    enemies: game_entity list;
    moving_platforms: game_entity list;
    objects: game_entity list
}