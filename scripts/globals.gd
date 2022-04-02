extends Node2D

onready var Player: Player = $"/root/Root/Player"
onready var StartLocation = $"/root/Root/Map/StartLocation"

var is_showing_dialog = false


func game_mode():
  if is_showing_dialog:
    return "dialog"

  return "normal"


func _ready():
  pass
  # print(Player)
