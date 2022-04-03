extends StaticBody2D

class_name Shadow

var time_since_spawn = 0

func _ready():
  var space = get_world_2d().get_direct_space_state()
  var center = global_position + Vector2(Globals.grid_size / 2, Globals.grid_size / 2)
  var lef_shadow = space.intersect_point(center - Vector2(Globals.grid_size, 0), 1, [self], 0b100)
  var rig_shadow = space.intersect_point(center + Vector2(Globals.grid_size, 0), 1, [self], 0b100)
  var top_shadow = space.intersect_point(center - Vector2(0, Globals.grid_size), 1, [self], 0b100)
  var bot_shadow = space.intersect_point(center + Vector2(0, Globals.grid_size), 1, [self], 0b100)
  
  if not lef_shadow.empty() and lef_shadow[0]['collider'].time_since_spawn > 1:
    $Graphic.material.set_shader_param("lef", true);
  if not rig_shadow.empty() and rig_shadow[0]['collider'].time_since_spawn > 1:
    $Graphic.material.set_shader_param("rig", true);
  if not top_shadow.empty() and top_shadow[0]['collider'].time_since_spawn > 1:
    $Graphic.material.set_shader_param("top", true);
  if not bot_shadow.empty() and bot_shadow[0]['collider'].time_since_spawn > 1:
    $Graphic.material.set_shader_param("bot", true);
  
  $Graphic.material.set_shader_param("offset", global_position / Globals.grid_size);

  var lfix = false
  var rfix = false
  var wall_mask = 0b10000
  if not space.intersect_point(center + Vector2(0, Globals.grid_size), 1, [], wall_mask).empty():
    lfix = true
    rfix = true
  elif not space.intersect_point(center + Vector2(-Globals.grid_size, Globals.grid_size), 1, [], wall_mask).empty():
    lfix = true
  elif not space.intersect_point(center + Vector2(Globals.grid_size, Globals.grid_size), 1, [], wall_mask).empty():
    rfix = true
    
  $Graphic.material.set_shader_param("lfix", lfix);
  $Graphic.material.set_shader_param("rfix", rfix);


func _process(delta):
  time_since_spawn += delta
  $Graphic.material.set_shader_param("time_alive", time_since_spawn);
