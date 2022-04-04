extends Area2D
onready var shadow_checker = get_node("/root/Root/ShadowChecker")

var triggered = false

func _on_EvilShadowTrigger_body_entered(body):
  if not triggered and body == Globals.Player:
    triggered = true
    print(self.name)
    player_trigger_evil_shadow()

func player_trigger_evil_shadow():
  yield(Globals.Player.start_dialog_co("FirstEvilShadowTrigger"), "completed")
  
  # TODO, add a timer to make this actually playable:
  if not Globals.DEBUG_NO_SHADOWS:
    yield(get_tree().create_timer(2.0), "timeout")
    shadow_checker.check_shadows()

func reset():
  triggered = false
