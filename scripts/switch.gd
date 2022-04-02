extends Node2D

signal player_enter()

func _on_Area_body_entered(body):
  if body == Globals.Player:
    emit_signal("player_enter")
