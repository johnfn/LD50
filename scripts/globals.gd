extends Node2D

onready var Player: Player = $"/root/Root/Player"
onready var StartLocation = $"/root/Root/Level1/StartLocation"

var is_showing_dialog = false


func game_mode():
  if is_showing_dialog:
    return "dialog"

  return "normal"
