extends Node2D

# These are NodePaths
export var linked_doors : Array

# These are Doors
var linked_door_nodes : Array
var has_been_triggered : bool = false

func _ready():
  for door_path in linked_doors:
    linked_door_nodes.append(get_node(door_path))

func _physics_process(delta):
  if not has_been_triggered:
    var space = get_world_2d().get_direct_space_state()
    var half_step = Vector2(Globals.grid_size / 2, Globals.grid_size / 2)
    var pointcast_result = space.intersect_point(global_position + half_step, 1, [], 0b100)
    if len(pointcast_result) > 0:
      has_been_triggered = true
      for door in linked_door_nodes:
        door.toggle_open()

func reset():
  has_been_triggered = false
