extends Area2D

func _on_EvilShadowTrigger_body_entered(body):
  if body == Globals.Player:
    player_trigger_evil_shadow()

func player_trigger_evil_shadow():
  yield(Globals.Player.start_dialog_co("FirstEvilShadowTrigger"), "completed")
  
  print("DONE")
