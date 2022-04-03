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
  var old_pos = $Graphics.global_position
  
  var collision = move_and_collide(direction)
  
  if collision and collision.collider is Node2D:
    var node: Node2D = collision.collider
    
    if node.is_in_group("Hole"):
      node.fill()
      drop_in_hole()
      
      return
  
  round_position(self)
  
  var new_pos = $Graphics.global_position

  $Tween.interpolate_property($Graphics, "global_position",
    old_pos, new_pos, 0.2,
    Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
  
  $Animation.play("Jump")
  
  $Tween.start()
  $Graphics.global_position = old_pos
