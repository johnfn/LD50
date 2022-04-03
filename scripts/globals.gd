extends Node2D

onready var Player: Player = $"/root/Root/Player"

var is_showing_dialog = false
var grid_size = 128


func game_mode():
  if is_showing_dialog:
    return "dialog"

  return "normal"
