extends Node2D

export var grid_offset : Vector2 = Vector2.ZERO
export var allcasters_raycast_mask = 0b101011000
export var nonblob_raycast_mask = 0b1010000
export var point_mask = 0b101011100

onready var player = Globals.Player
onready var shadow_spawner = get_node("../AllGameObjects/ShadowSpawner")

var raycast_instance: RayCast2D;
var tile_set = {}

var spawn_offsets = [
    Vector2(0, Globals.grid_size),
    Vector2(0, -Globals.grid_size),
    Vector2(Globals.grid_size, 0),
    Vector2(-Globals.grid_size, 0),
  ]

func _ready() -> void:  
  update_flood_fill_based_on_player_location()

func _get_light_sources():
  var arr = get_tree().get_nodes_in_group("torches") #TODO
  arr.append(player)
  return arr
  
func update_flood_fill_based_on_player_location():
  _update_flood_fill(player.global_position + Vector2(Globals.grid_size/2, Globals.grid_size/2))
  
func _point_unoccupied(location_under_test):
  var space = get_world_2d().get_direct_space_state()
  var cast_result = space.intersect_point(location_under_test, 1, [], point_mask)
  return cast_result.empty()

func _is_in_shadow(location_under_test, light_source):
  var space = get_world_2d().get_direct_space_state()
  var raycast_result = space.intersect_ray(location_under_test, light_source, [], allcasters_raycast_mask)
  return not raycast_result.empty()

func _is_walled_off(location_under_test, light_source):
  var space = get_world_2d().get_direct_space_state()
  var raycast_result = space.intersect_ray(location_under_test, light_source, [], nonblob_raycast_mask)
  return not raycast_result.empty()

var _debug = false
var _debug_lines = []
var _debug_dots = []
func _draw():
  if _debug:
    # useful for debugging shadow caster bugs
    for line in _debug_lines:
      draw_line(line[0], line[1], line[2])
      
    # useful for debugging flood fill bugs
    for dot in _debug_dots:
      draw_circle(dot[0], 10, Color.purple)
    
     
func _on_Button_pressed():
  check_shadows()
  
# TODO should the placed lights be able to spawn ESS?
# If not only check is_not_walled from the player position
func check_shadows():
  var light_sources = _get_light_sources()
  _debug_lines.clear()
  var half_step = Vector2(Globals.grid_size / 2, Globals.grid_size / 2)
  for location in tile_set.keys():
    var is_shaded = true
    for light_source in light_sources:
      var light_pos = light_source.global_position + half_step
      is_shaded = is_shaded and _is_in_shadow(location, light_pos)
#
#    if _debug:
#      _debug_lines.append([location, Globals.Player.global_position + half_step, Color.red if is_shaded else Color.green])

    if is_shaded and _point_unoccupied(location):
      var is_not_walled = false
      for light_source in light_sources:
        var light_pos = light_source.global_position + half_step
    
        if _debug:
          _debug_lines.append([location, light_pos, Color.red if _is_walled_off(location, light_pos) else Color.green])

        if not _is_walled_off(location, light_pos):
          is_not_walled = true
          break
      if is_not_walled:
        shadow_spawner.spawn_shadow(location - half_step)
        
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
      # print(point_results)
      
      # print("Unexpected, multiple collision items occupying same location: "+str(next) +", items:" + point_results[0].collider.get_parent().name + " " + point_results[1].collider.get_parent().name)
    
  tile_set = seen
  # print("Found ", len(tile_set), " locations to raycast to")
  if _debug:
    update()
