extends Node2D

export var initial_delay = 1

var shadow_spawner : Node2D
var activated = false

func reset():
  activated = false
  
  activate()

func activate():  
  if activated:
    return
  
  activated = true
  
  var non_dialog_frames = 0
  
  while non_dialog_frames < initial_delay * 60:
    if !Globals.Player.is_showing_dialog:
      non_dialog_frames += 1
      
      yield(get_tree(), "idle_frame")
  
  if !shadow_spawner:
    shadow_spawner = get_node("/root/Root/AllGameObjects/ShadowSpawner")
  shadow_spawner.spawn_shadow(global_position)

