extends Node2D

var is_open = false

func _unhandled_input(event):
  if not is_open and Input.is_action_just_pressed("interact"):
    var player_pos = Globals.Player.global_position
    if player_pos.distance_to(global_position) <= Globals.grid_size:
      Globals.encountered_torches = true
      Globals.num_torches += 1
      is_open = true
      $Open.visible = true
      $Closed.visible = false

func reset():
  is_open = false
  $Open.visible = false
  $Closed.visible = true
