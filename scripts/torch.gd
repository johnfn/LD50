extends Node2D

func reset():
  queue_free()

func _unhandled_input(event):
  if Input.is_action_just_pressed("interact"):
    if $Interactor.can_interact():
      $Interactor.interact()
      
      queue_free()
      Globals.num_torches += 1
