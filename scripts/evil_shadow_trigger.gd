extends Area2D
onready var shadow_checker = get_node("/root/Root/ShadowChecker")

var triggered = false

func _on_EvilShadowTrigger_body_entered(body):
  if not triggered and body == Globals.Player:
    triggered = true
    player_trigger_evil_shadow()

func player_trigger_evil_shadow():
  yield(Globals.Player.start_dialog_co("FirstEvilShadowTrigger"), "completed")
  
  # TODO, add a timer to make this actually playable:
  shadow_checker.check_shadows()

func reset():
  triggered = false
