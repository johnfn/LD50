extends Node2D

# These are NodePaths
export var linked_doors : Array

export var player_light_distance : float = 4000
export var torch_light_distance : float = 4000
export var raycast_mask : int = 0b1011100

# These are Doors
var linked_door_nodes : Array
var is_on : bool = false

func _ready():
  for door_path in linked_doors:
    linked_door_nodes.append(get_node(door_path))

func _physics_process(delta):
  if Globals.Player.position.distance_to(position) < player_light_distance:
    var space = get_world_2d().get_direct_space_state()
    var half_step = Vector2(Globals.grid_size / 2, Globals.grid_size / 2)
    var raycast_result = space.intersect_ray(position + half_step, Globals.Player.position + half_step, [], raycast_mask)
    if (len(raycast_result) > 0) == is_on:
      is_on = not is_on
      for door in linked_door_nodes:
        door.toggle_open()