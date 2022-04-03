extends KinematicBody2D

onready var og_position = global_position
var size = Globals.grid_size

func reset():
  global_position = og_position
  get_node("Shape").set_deferred("disabled", false)
  visible = true

func drop_in_hole():
  get_node("Shape").set_deferred("disabled", true)
  visible = false

func round_position(target):
  target.position.x = round(target.position.x / size) * size
  target.position.y = round(target.position.y / size) * size

func get_pushed(direction: Vector2):
  var collision = move_and_collide(direction)
  
  if collision and collision.collider is Node2D:
    var node: Node2D = collision.collider
    
    if node.is_in_group("Hole"):
      node.fill()
      drop_in_hole()
      
      return
  
  round_position(self)
