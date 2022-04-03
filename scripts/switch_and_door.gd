extends Node2D

onready var switch = $Switch
var doors = []

var is_door_open = false

func _ready():
  switch.connect("player_enter", self, "on_player_enter_switch")
  
  for child in get_children():
    if child.name.begins_with("Door"):
      doors.push_back(child)

func on_player_enter_switch():
  if not is_door_open:
    is_door_open = true
    
    for door in doors:
      # Why do you have to do this dumb thing?
      door.get_node("StaticBody/CollisionShape").set_deferred("disabled", true)
      door.get_node("LightOccluder2D").visible = false
      door.get_node("Sprite").modulate.a = 0.5
    return
  
  if is_door_open:
    is_door_open = false

    for door in doors:
      door.get_node("StaticBody/CollisionShape").set_deferred("disabled", false)
      door.get_node("LightOccluder2D").visible = true
      door.get_node("Sprite").modulate.a = 1.0
    return
