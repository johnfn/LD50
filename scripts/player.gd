class_name Player
extends KinematicBody2D

var size = 128
var tick = 0

# var ticks_to_move = 0.25
var ticks_to_move = 0.1
onready var dialog = $Dialog

func round_position(target):
  target.position.x = round(target.position.x / size) * size
  target.position.y = round(target.position.y / size) * size

func get_start_location():
  if Globals.current_level == 0:
    return
    
  var level = Globals.get_level(Globals.current_level)
  var start_location = level.get_node("Objects/StartLocation")
  
  start_location.visible = false
  
  self.global_position = start_location.global_position

func _ready():
  dialog.visible = false
  
  get_start_location()
  
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
        push_block(n, dist)

    round_position(self)
    
    tick = 0.0

func push_block(block, direction):
  var collision = block.move_and_collide(direction)
  
  if collision and collision.collider is Node2D:
    var node: Node2D = collision.collider
    
    if node.is_in_group("Hole"):
      node.queue_free()
      block.queue_free()
      
  round_position(block)

func start_dialog_co(dialog_name: String):
  if dialog_name == "WhereAmI":
    yield(dialog.show_dialog_co("Hey you triggered the dialog!"), "completed")
  
  if dialog_name == "FirstEvilShadowTrigger":
    yield(dialog.show_dialog_co("Oh no [insert ESS trigger text here]!"), "completed")


func enter_stairs():
  Globals.current_level += 1
  
  get_start_location()
