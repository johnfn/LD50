extends KinematicBody2D

var size = 64
var tick = 0

var ticks_to_move = 0.25

func round_position():
  position.x = round(position.x / size) * size
  position.y = round(position.y / size) * size

func _ready():
  round_position()

func _process(delta):
  var dist = Vector2.ZERO
  
  tick += delta
  
  if Input.is_action_pressed("ui_left") and dist == Vector2.ZERO:
    dist.x -= size
  
  if Input.is_action_pressed("ui_right") and dist == Vector2.ZERO:
    dist.x += size

  if Input.is_action_pressed("ui_up") and dist == Vector2.ZERO:
    dist.y -= size
  
  if Input.is_action_pressed("ui_down") and dist == Vector2.ZERO:
    dist.y += size
  
  var can_move = tick >= ticks_to_move
  
  if can_move and dist != Vector2.ZERO:
    move_and_collide(dist)
    round_position()
    tick = 0.0
  
  for i in get_slide_count():
      var collision = get_slide_collision(i)
      print(collision)

