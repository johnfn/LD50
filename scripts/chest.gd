extends Node2D

var is_open = false
onready var interactor = $Interactor

func _unhandled_input(event):
  if not is_open and Input.is_action_just_pressed("interact"):
    if $Interactor.can_interact():
      $Interactor.interact()
      
      Sfx.play_sound(Sfx.Chest)
      
      
      Globals.encountered_torches = true
      Globals.num_torches += 1
      is_open = true
      $Open.visible = true
      $Closed.visible = false

func reset():
  is_open = false
  $Open.visible = false
  $Closed.visible = true
  $Interactor.reset()
