extends Node2D

var Shadow = preload("res://Shadow.tscn")

func _ready():
  var shadow = Shadow.instance()
  
  
  shadow.position.x = 64
  shadow.position.y = 64

  add_child(shadow)
  

func _process(delta):
  var space = get_world_2d().get_direct_space_state()
  var results = space.intersect_point(
    Vector2(16, 16), 32, [], 2147483647, true
  )

  print(results)
