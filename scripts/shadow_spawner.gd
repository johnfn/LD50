extends Node2D

var Shadow = preload("res://Shadow.tscn")

export var grid_offset : Vector2 = Vector2.ZERO
export var grid_size : float = 128
export var shadow_propogation_time : float = 1
# TODO should this include the player?
export var raycast_mask = 0b11100
export var movable_raycast_mask = 0b1000000

var boundary_shadows = []
var spawn_offsets = [
    Vector2(0, grid_size),
    Vector2(0, -grid_size),
    Vector2(grid_size, 0),
    Vector2(-grid_size, 0),
  ]

func _ready():
  spawn_shadow(grid_offset)
  
func spawn_shadow(spawn_position: Vector2):
  var shadow = Shadow.instance()
  shadow.position = spawn_position
  shadow.modulate = Color(1, 1, 1, 0)
  add_child(shadow)
  boundary_shadows.append(shadow)


func _physics_process(delta):
  if Globals.game_mode() != "normal":
    return
  
  var space = get_world_2d().get_direct_space_state()
  var to_remove = []
  
  for i in range(len(boundary_shadows)):
    var shadow : Shadow = boundary_shadows[i]
    if shadow.time_since_spawn > shadow_propogation_time:
      var shadow_center = shadow.position + Vector2(grid_size / 2, grid_size / 2)
      shadow.modulate = Color(1, 1, 1, 1)
      var blocked = 0
      for spawn_offset in spawn_offsets:
        var raycast_results = space.intersect_ray(shadow_center, shadow_center + spawn_offset, [shadow], raycast_mask)
        if len(raycast_results) > 0:
          blocked += 1
        else:
          raycast_results = space.intersect_ray(shadow_center, shadow_center + spawn_offset, [shadow], movable_raycast_mask)
          if len(raycast_results) == 0:
            spawn_shadow(shadow.position + spawn_offset)
            blocked += 1
      
      if blocked == len(spawn_offsets):
        to_remove.append(i)
    else:
      shadow.time_since_spawn += delta
      shadow.modulate = Color(1, 1, 1, shadow.time_since_spawn / shadow_propogation_time)
  
  for i in range(len(to_remove)):
    boundary_shadows.remove(to_remove[len(to_remove)-1-i])
    
