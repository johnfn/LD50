extends Node2D

class_name Door

export var is_door_open = false

func _ready():
  if is_door_open:
    is_door_open = false
    toggle_open()

func toggle_open():
  if is_door_open:
    is_door_open = false
    get_node("StaticBody/CollisionShape").set_deferred("disabled", false)
    get_node("LightOccluder2D").visible = true
    get_node("Sprite").modulate.a = 1.0
  else:
    is_door_open = true
    get_node("StaticBody/CollisionShape").set_deferred("disabled", true)
    get_node("LightOccluder2D").visible = false
    get_node("Sprite").modulate.a = 0.5  
