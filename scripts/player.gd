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


func get_occluder_polygons():
  var occluders = get_tree().get_nodes_in_group('occluders')
  
  var polygons = []
  for o in occluders:
    var poly = o.occluder.polygon
    for i in range(len(poly)):
      poly[i] += (o.position - self.position)

    polygons.append(o.occluder.polygon)
  
  return polygons

func fov():
  pass

func _draw():
  var points = PoolVector2Array()
  var colour = PoolColorArray()

  points = [Vector2(100,100), Vector2(200,100), Vector2(200,200), Vector2(100,200)]
  colour = [Color(0, 0, 255)]
  # draw_polygon(points, colour)
  
  var fov_computer = $"/root/Root/fov"
  var polygons = get_occluder_polygons()
  var fov_center = Vector2(0, 0)
  var fov_poly = fov_computer.get_fov_from_polygons(polygons, fov_center)
  
  # fov_poly.invert()
  
  print("result: s", fov_poly)
  
  # fov_poly.invert()
  
  var stupid = [
    Vector2(0, 0),
    Vector2(256, 0),
    Vector2(256, 256),
    # Vector2(0, 256),
   ]
  
  draw_colored_polygon(fov_poly, Color.red)

func _ready():
  dialog.visible = false
  
  go_to_start_location()
  round_position()

func _process(delta):
  if Globals.game_mode() != "normal":
    return
  
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
      # print(collision)

func start_dialog(dialog_name: String):
  print(dialog_name)
  print(dialog)
  print(dialog.get_node("DialogUpscaler"))
  
  # WhereAmI
  dialog.show_dialog_co("Hey you triggered the dialog!")
