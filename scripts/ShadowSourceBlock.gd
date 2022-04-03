extends Node2D

export var initial_delay = 1

var shadow_spawner : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
  activate()
  
func reset():
  # empty, let me just have an empty function damnit
  var a = 5

func activate():  
  yield(get_tree().create_timer(initial_delay), "timeout")
  if !shadow_spawner:
    shadow_spawner = get_node("/root/Root/AllGameObjects/ShadowSpawner")
  shadow_spawner.spawn_shadow(global_position)

