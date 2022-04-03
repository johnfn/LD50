class_name Player
extends KinematicBody2D

var size = 128
var tick = 0

# var ticks_to_move = 0.25
var ticks_to_move = 0.1
onready var dialog = $Dialog

func go_to_start_location():
  position = Globals.StartLocation.global_position
  Globals.StartLocation.queue_free()

func round_position():
  position.x = round(position.x / size) * size
  position.y = round(position.y / size) * size

func _ready():
  dialog.visible = false
  
  go_to_start_location()
  round_position()

func _process(delta):
  if Globals.game_mode() != "normal":
    return
  
  var dist = Vector2.ZERO
  
  tick += delta
  
  if Input.is_action_pressed("left") and dist == Vector2.ZERO:
    dist.x -= size
  
  if Input.is_action_pressed("right") and dist == Vector2.ZERO:
    dist.x += size

  if Input.is_action_pressed("up") and dist == Vector2.ZERO:
    dist.y -= size
  
  if Input.is_action_pressed("down") and dist == Vector2.ZERO:
    dist.y += size
  
  var can_move = tick >= ticks_to_move
  
  if can_move and dist != Vector2.ZERO:
    move_and_collide(dist)
    round_position()
    
    tick = 0.0
  
  for i in get_slide_count():
      var collision = get_slide_collision(i)
      # print(collision)

func start_dialog(dialog_name: String):
  # WhereAmI
  dialog.show_dialog_co("Hey you triggered the dialog!")
