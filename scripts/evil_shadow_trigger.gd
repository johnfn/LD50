extends Area2D
onready var shadow_checker = get_node("/root/Root/ShadowChecker")

var triggered = false
export var once_only = false

func _on_EvilShadowTrigger_body_entered(body):
  # Probably bad but it prevents things from getting confusing AF
  if Globals.UI.EssTimeLeft.visible:
    return
  
  if not triggered and body == Globals.Player:
    if once_only:
      triggered = true
    
    # trying re-entrant triggers, i think itll work better
    player_trigger_evil_shadow()

func player_trigger_evil_shadow():
  yield(Globals.Player.start_dialog_co("FirstEvilShadowTrigger"), "completed")
  
  if not Globals.DEBUG_NO_SHADOWS:  
    for x in range(3):
      Globals.UI.EssTimeLeft.text = str(3 - x)
      Globals.UI.EssTimeLeft.visible = true
      
      Sfx.play_sound(Sfx.Tick1, true)
      yield(get_tree().create_timer(1), "timeout")
    
    Globals.UI.EssTimeLeft.visible = false
    Sfx.play_sound(Sfx.BlobSpawn, true)
    shadow_checker.check_shadows()

func reset():
  triggered = false
