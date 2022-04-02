extends Node2D

onready var switch = $Switch
onready var door = $Door

var is_door_open = false

func _ready():
  switch.connect("player_enter", self, "on_player_enter_switch")

func on_player_enter_switch():
  if not is_door_open:
    is_door_open = true
    
    $Door/StaticBody/CollisionShape.set_deferred("disabled", true)
    $Door/Sprite.modulate.a = 0.5
