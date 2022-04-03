tool
extends Node2D

enum Facing {
  North,
  East,
  South,
  West,
  # NorthEast,
  SouthEast,
  # NorthWest,
  SouthWest,
}

export(Facing) var facing = Facing.North

func _ready():
  var grid_size = 128
  var space = get_world_2d().get_direct_space_state()
  var center = global_position + Vector2(grid_size / 2, grid_size / 2)
  var is_wall = not space.intersect_point(center - Vector2(grid_size, 0), 1, [self], 0b10000).empty()

  print(is_wall)

func _process(d: float):
  if not Engine.editor_hint:
    return
  
  for child in $Graphics.get_children():
    child.visible = false
  
  if facing == Facing.North:
    $Graphics/WallN.visible = true
  if facing == Facing.East:
    $Graphics/WallE.visible = true
  if facing == Facing.South:
    $Graphics/WallS.visible = true
  if facing == Facing.West:
    $Graphics/WallW.visible = true
