class_name Player
extends KinematicBody2D

var size = 128
var tick = 0
onready var shadow_checker = get_node("/root/Root/ShadowChecker")

# var ticks_to_move = 0.25
var ticks_to_move = 0.1
onready var dialog = $Dialog
var torch = preload("res://Torch.tscn")
export var torch_parent : NodePath
onready var torch_parent_node = get_node(torch_parent)

func respawn(spawn_point: Vector2):
  self.global_position = spawn_point

func round_position(target):
  target.position.x = round(target.position.x / size) * size
  target.position.y = round(target.position.y / size) * size

func move_to_level_start():
  if Globals.current_level == 0:
    return

  var level = Globals.get_level(Globals.current_level)
  var start_location = level.get_node("Objects/StartLocation")

  start_location.visible = false
  
  self.global_position = start_location.global_position
  shadow_checker.update_flood_fill_based_on_player_location()

func _ready():
  dialog.visible = false
  move_to_level_start()
  round_position(self)
  StateManager.checkpoint(global_position)

func _unhandled_input(event):
  if Input.is_action_just_pressed("place item") and Globals.num_torches > 0:
    var already_torched = false
    for torch in get_tree().get_nodes_in_group("torches"):
      if torch.global_position.distance_to(global_position) < Globals.grid_size:
        already_torched = true
    if not already_torched:
      Globals.num_torches -= 1
      var new_torch = torch.instance()
      new_torch.add_to_group("torches")
      torch_parent_node.add_child(new_torch)
      new_torch.global_position = global_position
    
  if Input.is_action_just_pressed("respawn"):
    StateManager.return_to_checkpoint()
    

func _physics_process(delta):
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
      node.fill()
      block.drop_in_hole()
      
  round_position(block)

func start_dialog_co(dialog_name: String):
  if dialog_name == "WhereAmI":
    yield(dialog.show_dialog_co("Hey you triggered the dialog!"), "completed")
  
  if dialog_name == "FirstEvilShadowTrigger":
    yield(dialog.show_dialog_co("Oh no [insert ESS trigger text here]!"), "completed")


func enter_stairs():
  Globals.current_level += 1
  
  move_to_level_start()
