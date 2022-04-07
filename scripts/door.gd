extends Node2D

class_name Door

export var is_door_open = false
onready var og_is_door_open = is_door_open
onready var tile_door_open = $TileDoorOpen 
onready var tile_door_closed = $TileDoor

onready var initial_material_c = tile_door_closed.material
onready var initial_material_o = tile_door_open.material
var glow_material = preload("res://assets/GlowMaterial.tres")

var glowing = false
var initial_modulate = Color(1, 1, 1, 1)
var tween1: Tween
var tween2: Tween

func _ready():
  tween1 = Tween.new()
  tween2 = Tween.new()
  
  add_child(tween1)
  add_child(tween2)
  
  if is_door_open:
    is_door_open = false
    toggle_open()
  
  update_door_sprites()

func update_door_sprites():
  tile_door_open.visible = is_door_open
  tile_door_closed.visible = not is_door_open
  
  tile_door_open.material = glow_material if glowing else initial_material_o
  tile_door_closed.material = glow_material if glowing else initial_material_c
  if tile_door_open.get_child_count() > 0:
    tile_door_open.get_child(0).material = glow_material if glowing else null
  
  if glowing:
    tween1.interpolate_property(
      tile_door_open, "modulate", 
      Color(2, 2, 2, 1), Color(.5, .5, .5, 1), 1,
      Tween.TRANS_QUAD, Tween.EASE_IN)
    tween1.start()
    tween1.repeat = true
    tween2.interpolate_property(
      tile_door_closed, "modulate", 
      Color(2, 2, 2, 1), Color(.5, .5, .5, 1), 1,
      Tween.TRANS_QUAD, Tween.EASE_IN)
    tween2.start()
    tween2.repeat = true
    
    # tile_door_open.modulate = Color(2, 2, 2, 1)
    # tile_door_closed.modulate = Color(2, 2, 2, 1)
  else:
    tween1.stop(tile_door_open)
    tween2.stop(tile_door_closed)
    tile_door_open.modulate = initial_modulate
    tile_door_closed.modulate = initial_modulate

var blocked_closing = false
func toggle_open():
  if is_door_open:
    is_door_open = false
    if Globals.Player.global_position != global_position:
      get_node("StaticBody/CollisionShape").set_deferred("disabled", false)
    else:
      blocked_closing = true
    get_node("LightOccluder2D").visible = true
  else:
    is_door_open = true
    get_node("StaticBody/CollisionShape").set_deferred("disabled", true)
    get_node("LightOccluder2D").visible = false
  
  update_door_sprites()

func _process(delta):
  if is_door_open == false && Globals.Player.global_position == global_position:
    blocked_closing = true
    get_node("StaticBody/CollisionShape").set_deferred("disabled", true)
    print ("player stuck in door, disabling collider")
  if blocked_closing && Globals.Player.global_position != global_position && Globals.Player.global_position.distance_to(global_position) <= 130:
    blocked_closing = false
    get_node("StaticBody/CollisionShape").set_deferred("disabled", false)
    print ("re-enabling collider")

func reset():
  if og_is_door_open != is_door_open:
    toggle_open()


func glow():
  glowing = true
  update_door_sprites()

func glow_stop():
  glowing = false
  update_door_sprites()

