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
  interactor.interaction_name = "Pick up lantern"
  add_child(i)
  i.position = pos

func _unhandled_input(event):
  if Input.is_action_just_pressed("interact"):
    if $Interactor.can_interact():
      $Interactor.interact()
      
      queue_free()
      Globals.num_torches += 1
