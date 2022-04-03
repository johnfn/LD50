extends Node2D

var Shadow = preload("res://Shadow.tscn")

export var grid_offset : Vector2 = Vector2.ZERO
export var grid_size : float = 128
export var raycast_mask = 0b1010100 # things that stop shadowcasters (walls, doors, etc)
export var shadowcasters_raycast_mask = 0b100000000 # things that cast shadow blob generators

onready var player = Globals.Player
onready var shadow_spawner = get_node("../ShadowSpawner")

var raycast_instance: RayCast2D;
var tile_set = {}

var spawn_offsets = [
    Vector2(0, grid_size),
    Vector2(0, -grid_size),
    Vector2(grid_size, 0),
    Vector2(-grid_size, 0),
  ]

func _ready() -> void:  
  update_flood_fill_based_on_player_location()

func _get_light_sources():
  var arr = get_tree().get_nodes_in_group("torches") #TODO
  arr.append(player)
  return arr
  
func update_flood_fill_based_on_player_location():
  _update_flood_fill(player.global_position + Vector2(grid_size/2, grid_size/2))
  
      
func _cast_ray(location_under_test, light_source):
  var space = get_world_2d().get_direct_space_state()
  var raycast_result = space.intersect_ray(location_under_test, light_source, [], shadowcasters_raycast_mask)
  if !raycast_result.empty():    
    # hit a shadow caster
    # Check if our hit is at our current location
    if raycast_result["position"] == location_under_test:
      return
    
    # check if we hit a wall
    var los_blocker_cast_result = space.intersect_ray(location_under_test, light_source, [raycast_result["collider"]], raycast_mask)
    if los_blocker_cast_result.empty():
      # we did not get obstructed by any walls/doors/etc. But DID hit a shadow caster
      # this means this location spawns a blob
      shadow_spawner.spawn_shadow(location_under_test - Vector2(grid_size/2, grid_size/2))
      if _debug:
        _debug_lines.append([location_under_test, light_source, Color.green])
    else:
      if _debug:
        _debug_lines.append([location_under_test, light_source, Color.red])

var _debug = false
var _debug_lines = []
var _debug_dots = []
func _draw():
  if _debug:
    # useful for debugging shadow caster bugs
    for line in _debug_lines:
      draw_line(line[0], line[1], line[2])
      
    # useful for debugging flood fill bugs
    #for dot in _debug_dots:
     # draw_circle(dot[0], 10, Color.purple)
    
     
func _on_Button_pressed():
  check_shadows()
  
func check_shadows():
  var light_sources = _get_light_sources()
  _debug_lines.clear()
  for light_source in light_sources:
    for location in tile_set.keys():
      _cast_ray(location, light_source.global_position)
  if _debug:
    update() 

func _update_flood_fill(origin : Vector2):  
  var immovable_mask = 0b11000
  var space = get_world_2d().get_direct_space_state()
  var to_propogate = []
  var seen = {} # using the keys as a set
  
  to_propogate.append(origin)
  seen[origin]=null #don't care about the values, only the keys
  var breakout_counter = 0
  while len(to_propogate) > 0:
    breakout_counter+=1
    if breakout_counter > 1000:
      printerr("Reached flood fill depth, is the map bounded? Or maybe its just kinda big. Should work, but inefficient")
      break
    var current = to_propogate[0]
    to_propogate.remove(0)
    for spawn_offset in spawn_offsets:
      var next = current + spawn_offset
      var point_results = space.intersect_point(next, 30, [], immovable_mask)
      if len(point_results) == 0:
        if !seen.has(next) && (to_propogate.find(next)==-1):
          to_propogate.append(current+spawn_offset)
          seen[current+spawn_offset] = null # idc about the values, just the keys
          if _debug:
            _debug_dots.append([current+spawn_offset])
        continue
      if len(point_results) == 1:
        continue
      print("Unexpected, multiple collision items occupying same location: "+str(next) +", items:" + str(len(point_results)))
    
  tile_set = seen
  if _debug:
    update()
