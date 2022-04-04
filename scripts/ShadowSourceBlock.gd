extends Node2D

export var initial_delay = 1

var shadow_spawner : Node2D
  
func reset():
  pass
#  activate()

func activate():  
  yield(get_tree().create_timer(initial_delay), "timeout")
  if !shadow_spawner:
    shadow_spawner = get_node("/root/Root/AllGameObjects/ShadowSpawner")
  shadow_spawner.spawn_shadow(global_position)

