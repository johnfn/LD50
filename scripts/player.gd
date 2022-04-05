class_name Player
extends KinematicBody2D

var size = Globals.grid_size
var tick = 0
onready var shadow_checker = get_node("/root/Root/ShadowChecker")

export var screen_wipe_time = 1
var wipe_time = 0
var enclose_time = 0
var is_dead = false

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
  if Globals.current_level == 1:
    trigger_level_start_shadows()
  is_dead = false

func round_position(target):
  target.position.x = round(target.position.x / size) * size
  target.position.y = round(target.position.y / size) * size

func move_to_level_start():
  if Globals.current_level == 0 :
    return
    
  if Globals.current_level == 6 :
    Sfx.play_song("end")

  var level = Globals.get_level(Globals.current_level)
  var start_location = level.get_node("Objects/StartLocation")

  start_location.visible = false
  
  self.global_position = start_location.global_position
  
  # leave this here >:(
  trigger_level_start_shadows()

func trigger_level_start_shadows():
  if not Globals.DEBUG_NO_SHADOWS:
    var level = Globals.get_level(Globals.current_level)
    var shadow_source = level.get_node("Objects/ShadowSourceBlock")
    
    shadow_checker.update_flood_fill_based_on_player_location()
    
    if shadow_source:
      shadow_source.activate()

func _ready():
  if Globals.started:
    Sfx.play_song("level")
#  if not Globals.IS_DEBUG:
#    $Graphics/LightSource.visible = true
#  else:
#    $Graphics/LightSource.shadow_enabled = false

  dialog.visible = false
  if not Globals.IS_DEBUG:
    move_to_level_start()
  else:
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
      Sfx.play_sound(Sfx.DropLantern)
      Globals.num_torches -= 1
      var new_torch = torch.instance()
      new_torch.add_to_group("torches")
      torch_parent_node.add_child(new_torch)
      new_torch.global_position = global_position
    
  if Input.is_action_just_pressed("respawn"):
    wipe_time = 0.001
    is_dead = true
  
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
  
  if wipe_time > 0:
    wipe_time += delta
  if enclose_time > 0:
    enclose_time += delta
  var wipe_perc = wipe_time / screen_wipe_time
  var enclose_perc = enclose_time / screen_wipe_time
  if wipe_perc > 0.5 and wipe_perc - delta / screen_wipe_time <= 0.5:
    if is_dead:
      StateManager.return_to_checkpoint()
    else:
      move_to_level_start()
  if enclose_perc > 0.5 and enclose_perc - delta / screen_wipe_time <= 0.5:
    if is_dead:
      StateManager.return_to_checkpoint()
  var overlay = $CanvasLayer/Overlay
  overlay.material.set_shader_param("wipe_percent", wipe_perc)
  overlay.material.set_shader_param("enclose_percent", enclose_perc)
  if wipe_time > screen_wipe_time:
    wipe_time = 0
  if enclose_time > screen_wipe_time:
    enclose_time = 0
  
  if is_dead or wipe_time > 0:
    return
  
  tick += delta
  var can_move = tick >= ( 0.05 if Input.is_key_pressed(KEY_SHIFT) else ticks_to_move )
  
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
  Sfx.play_sound(Sfx.StatueSlide)
  block.get_pushed(direction)

var is_first_lantern = true
var is_first_shadow = true

func start_dialog_co(dialog_name: String):
  if dialog_name == "OpenChestLantern":
    if is_first_lantern and not Globals.IS_DEBUG:
      is_first_lantern = false
      
      yield(dialog.show_dialog_co("Hey, I found a lantern!"), "completed")
      yield(dialog.show_dialog_co("I can drop these with Q, and I can pick them up later."), "completed")
      yield(dialog.show_dialog_co("If I place them, they might keep the shadows away... for a little while."), "completed")
    else:
      yield(dialog.show_dialog_co("I got a lantern."), "completed")
  
  if dialog_name == "WhereAmI":
    yield(dialog.show_dialog_co("Whoa, so THIS is what the Underground Archives look like."), "completed")
    yield(dialog.show_dialog_co("What was it the Curator wanted me to go grab again..."), "completed")
    yield(dialog.show_dialog_co("Oh right! The Unholy Grail!"), "completed")
    yield(dialog.show_dialog_co("He said it was in the eighth floor of the basement, so I'd better get going."), "completed")
    yield(dialog.show_dialog_co("And he also said to beware the dark...?"), "completed")
    yield(dialog.show_dialog_co("But that's so silly. I'm an adult!"), "completed")
    yield(dialog.show_dialog_co("Now, where might those steps to the second floor be?"), "completed")
  
  if dialog_name == "FirstDoor":
    yield(dialog.show_dialog_co("Huh? A door? But the Curator never gave me a key..."), "completed")
    yield(dialog.show_dialog_co("Maybe there's another way to open it."), "completed")

  if dialog_name == "Atrium1":
    yield(dialog.show_dialog_co("Yikes, I've never seen shadows that could chase someone before!"), "completed")
    yield(dialog.show_dialog_co("Maybe there's more to the Archives than meets the eye."), "completed")
    yield(dialog.show_dialog_co("But that's not gonna stop me! Second floor, here I come!"), "completed")

  if dialog_name == "FirstEvilShadowTrigger":
    if is_first_shadow and not Globals.IS_DEBUG:
      is_first_shadow = false
      yield(dialog.show_dialog_co("Hey, what's that ticking sound?"), "completed")
    else:
      yield(dialog.show_dialog_co("Oh no, the shadows are coming back!"), "completed")
  
  if dialog_name == "L2Start":
    yield(dialog.show_dialog_co("Whoa, the second floor looks even wilder than the first one."), "completed")
    yield(dialog.show_dialog_co("I gotta be careful to escape the shadows if they start coming back!"), "completed")
    yield(dialog.show_dialog_co("Why the heck are these shadows chasing me?!"), "completed")
    yield(dialog.show_dialog_co("...then again, why the heck is there a maze in the basement of a museum??"), "completed")
    yield(dialog.show_dialog_co("Well, whatever. I just need to keep searching for that Unholy Grail."), "completed")
    yield(dialog.show_dialog_co("Maybe if I could find something to help keep the shadows at bay... like a light source or something..."), "completed")

  if dialog_name == "YouWinKinda":
    yield(dialog.show_dialog_co("YES! Finally!!"), "completed")
    yield(dialog.show_dialog_co("The Unholy Grail! I'm so glad it's actually here. The Curator is going to be so happy with me!"), "completed")
    yield(dialog.show_dialog_co("But wait..."), "completed")
    yield(dialog.show_dialog_co("...how do I get back up?"), "completed")
      
        

func start_dying_co():
  yield(get_tree(), 'idle_frame')
  
  enclose_time = 0.001
  is_dead = true
  
  for x in range(50):
    yield(get_tree(), 'idle_frame')
    modulate = Color(1, 1, 1, 1.0 - float(x) / float(50))
  
  modulate = Color(1, 1, 1, 1)

func enter_stairs(var from_level):
  Globals.current_level = from_level + 1
  
  wipe_time = 0.001
