extends Node2D

func _on_Area_body_entered(body):
  if body == Globals.Player:
    print("enter_stairs")
    Globals.Player.enter_stairs()
