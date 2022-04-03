extends Node2D

# These are NodePaths
export var linked_doors : Array

# These are Doors
var linked_door_nodes : Array

func _ready():
  for door_path in linked_doors:
    linked_door_nodes.append(get_node(door_path))

func _on_Area_body_entered(body):
  # This is hopefully only shadows
  if body != Globals.Player:
    for door in linked_door_nodes:
      door.toggle_open()
