extends Node2D

var Shadow = preload("res://Shadow.tscn")

export var grid_offset : Vector2 = Vector2.ZERO
export var grid_size : float = 64

var boundary_shadows = []

func _ready():
  var shadow = Shadow.instance()
  
  
  shadow.position.x = 128
  shadow.position.y = 128

  add_child(shadow)
  

func _process(delta):
  var space = get_world_2d().get_direct_space_state()
  var results = space.intersect_point(
    Vector2(32, 32), 32, [], 2147483647, true
  )

func _physics_process(delta):
  var to_remove = []
  for i in range(len(boundary_shadows)):
    var shadow = boundary_shadows[i]
  
  for i in range(len(to_remove)):
    boundary_shadows.remove(to_remove[len(to_remove)-1-i])
