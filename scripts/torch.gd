extends Node2D

var interactor = preload("res://Interactor.tscn")

func reset():
  queue_free()

func _ready():
  initially_hide_interactor()

# hide interactor for a sec so that it doesnt seem spammy when u immediately
# drop lantern
func initially_hide_interactor():
  var pos = $Interactor.position
  $Interactor.queue_free()
  
  yield(get_tree().create_timer(1.0), "timeout")
  
  var i = interactor.instance()
  i.interaction_name = "Pick up lantern"
  add_child(i)
  i.position = pos

func _unhandled_input(event):
  if Input.is_action_just_pressed("interact"):
    # == null accomodates for the period when the interactor does not exist
    
    if $Interactor == null or $Interactor.can_interact():
      # Pick up the torch
      
      if $Interactor != null:
        $Interactor.interact()
      
      queue_free()
      Globals.num_torches += 1
      
      Sfx.play_sound(Sfx.PickupLantern)
