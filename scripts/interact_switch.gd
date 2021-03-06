extends Node2D

export var is_on : bool = false
# These are NodePaths
export var linked_doors : Array

# These are Doors
var linked_door_nodes : Array
onready var og_is_on = is_on

func _ready():
  for door_path in linked_doors:
    linked_door_nodes.append(get_node(door_path))

func _unhandled_input(event):
  if Input.is_action_just_pressed("interact"):
    var player_pos = Globals.Player.global_position
    
    if player_pos.distance_to(global_position) <= Globals.grid_size:
      is_on = not is_on
      for door in linked_door_nodes:
        door.toggle_open()

func reset():
  is_on = og_is_on
