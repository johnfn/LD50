class_name Player
extends KinematicBody2D

var size = Globals.grid_size
var tick = 0
onready var shadow_checker = get_node("/root/Root/ShadowChecker")

# var ticks_to_move = 0.25
var ticks_to_move = 0.25
onready var dialog = $Dialog
var torch = preload("res://Torch.tscn")
export var torch_parent : NodePath
onready var torch_parent_node = get_node(torch_parent)
var press_order = ['left', 'right', 'up', 'down']
var poss_move_dirs = []
var move_raycast_mask = 0b1111100

func respawn(spawn_point: Vector2):
  self.global_position = spawn_point
  shadow_checker.update_flood_fill_based_on_player_location()

func round_position(target):
  target.position.x = round(target.position.x / size) * size
  target.position.y = round(target.position.y / size) * size

func move_to_level_start():
  if Globals.current_level == 0 :
    return

  var level = Globals.get_level(Globals.current_level)
  var start_location = level.get_node("Objects/StartLocation")

  start_location.visible = false
  
  self.global_position = start_location.global_position

func trigger_level_start_shadows():
  if not Globals.DEBUG_NO_SHADOWS:
    var level = Globals.get_level(Globals.current_level)
    var shadow_source = level.get_node("Objects/ShadowSourceBlock")
    
    shadow_checker.update_flood_fill_based_on_player_location()
    
    if shadow_source:
      shadow_source.activate()

func _ready():
  $Graphics/LightSource.visible = true
  dialog.visible = false
  if not Globals.IS_DEBUG:
    move_to_level_start()
  
  trigger_level_start_shadows()
    
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
  
  var new_press_order = []
  for action_name in press_order:
    if Input.is_action_just_pressed(action_name):
      new_press_order.push_front(action_name)
    else:
      new_press_order.push_back(action_name)
  press_order = new_press_order
  
  poss_move_dirs = []
  var hmoved = false
  var vmoved = false
  for action_name in press_order:
    if Input.is_action_pressed(action_name):
      var dir = Vector2.ZERO
      if action_name == 'left' and not hmoved:
        dir.x -= 1
        hmoved = true
      elif action_name == 'right' and not hmoved:
        dir.x += 1
        hmoved = true
      elif action_name == 'up' and not vmoved:
        dir.y -= 1
        vmoved = true
      elif action_name == 'down' and not vmoved:
        dir.y += 1
        vmoved = true
      if dir != Vector2.ZERO:
        poss_move_dirs.append(dir)

func set_facing(dir):
  if dir == Vector2(0, 1):
    $Graphics/Sprite.animation = "down"
  elif dir == Vector2(0, -1):
    $Graphics/Sprite.animation = "up"
  elif dir == Vector2(-1, 0):
    $Graphics/Sprite.animation = "left"
  elif dir == Vector2(1, 0):
    $Graphics/Sprite.animation = "right"


func _physics_process(delta):
  if Globals.game_mode() != "normal":
    return
  
  tick += delta
  var can_move = tick >= ticks_to_move
  
  if can_move and len(poss_move_dirs) > 0:
    var target_pos = null
    var space = get_world_2d().get_direct_space_state()
    var half_step = Vector2(Globals.grid_size / 2, Globals.grid_size / 2)
    
    set_facing(poss_move_dirs[0])
    
    var actual_move_dir = null
    
    for possible_move_dir in poss_move_dirs:
      target_pos = global_position + Globals.grid_size * possible_move_dir
      var cast_result = space.intersect_point(target_pos + half_step, 1, [], move_raycast_mask)
      if cast_result.empty():
        actual_move_dir = possible_move_dir
    
    if actual_move_dir != null:
      move_in_direction(actual_move_dir)
    
# Now that we've validated that it's safe to move towards move_dir, 
# let's actually do it!
func move_in_direction(move_dir):
  var old_global_position = $Graphics.global_position
  
  Sfx.step()
  
  # We want to move them to the next square immediately, but
  # then play the animation in the next 0.2 sec
  
  # Move and resolve collisions immediately, so that we don't induce race conditions / out of sync stuff
  
  var target_pos = global_position + Globals.grid_size * move_dir
  set_facing(move_dir)
  
  var collision = move_and_collide(target_pos - global_position)
  
  if collision and collision.collider is KinematicBody2D:
    var n: KinematicBody2D = collision.collider
    if n.is_in_group("Pushable"):
      push_block(n, target_pos - global_position)
  
  # Move sprite back so we can animate it nicely
  
  var new_pos = $Graphics.global_position
  
  $Graphics.global_position = old_global_position
  
  $Tween.interpolate_property($Graphics, "position",
    $Graphics.position, Vector2.ZERO, 0.2,
    Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

  $Tween.start()
  
  $Animation.play("Jump")
  
  round_position(self)
  tick = 0.0
  
func push_block(block, direction):
  block.get_pushed(direction)

func start_dialog_co(dialog_name: String):
  if dialog_name == "WhereAmI":
    yield(dialog.show_dialog_co("Hey you triggered the dialog!"), "completed")
  
  if dialog_name == "FirstEvilShadowTrigger":
    yield(dialog.show_dialog_co("Oh no [insert ESS trigger text here]!"), "completed")

func start_dying_co():
  yield(get_tree(), 'idle_frame')
  
  print("YOU HAVE DIED")
  
  # TODO: Death cinematic
  
  StateManager.return_to_checkpoint()
  trigger_level_start_shadows()
  

func enter_stairs(var from_level):
  Globals.current_level = from_level + 1
  
  move_to_level_start()
