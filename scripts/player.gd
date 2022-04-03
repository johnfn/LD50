class_name Player
extends KinematicBody2D

var size = 128
var tick = 0

# var ticks_to_move = 0.25
var ticks_to_move = 0.1
onready var dialog = $Dialog
export var current_level = 1

func round_position(target):
  target.position.x = round(target.position.x / size) * size
  target.position.y = round(target.position.y / size) * size

func get_starting_position():
  var levels = 

func _ready():
  dialog.visible = false
  
  get_starting_position()
  
  round_position(self)

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
    var collision = move_and_collide(dist)

    if collision and collision.collider is KinematicBody2D:
      var n: KinematicBody2D = collision.collider

      if n.is_in_group("Pushable"):
        n.move_and_collide(dist)
        round_position(n)

    round_position(self)
    
    tick = 0.0

func start_dialog_co(dialog_name: String):
  if dialog_name == "WhereAmI":
    yield(dialog.show_dialog_co("Hey you triggered the dialog!"), "completed")
  
  if dialog_name == "FirstEvilShadowTrigger":
    yield(dialog.show_dialog_co("Oh no [insert ESS trigger text here]!"), "completed")


func enter_stairs():
  print("Enter stairs")

