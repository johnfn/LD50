extends Node2D

# These are NodePaths
export var linked_doors : Array

# These are Doors
var linked_door_nodes : Array

func _ready():
  for door_path in linked_doors:
    linked_door_nodes.append(get_node(door_path))

func _physics_process(delta):
  pass
