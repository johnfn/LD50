extends Node2D

func _on_Area_body_entered(body):
  if body == Globals.Player:
    Globals.Player.enter_stairs()
