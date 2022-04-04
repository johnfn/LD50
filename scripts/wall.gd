tool
extends Node2D

enum Facing {
  North,
  East,
  South,
  West,
  
  EastTall,
  WestTall,
  
  # NorthEast,
  SouthEastTall,
  # NorthWest,
  SouthWestTall,
}

export(Facing) var facing = Facing.North

func _ready():
  set_wall_vis()

func set_wall_vis():
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
    
  if facing == Facing.EastTall:
    $Graphics/WallETall.visible = true
    
  if facing == Facing.WestTall:
    $Graphics/WallWTall.visible = true
    
  if facing == Facing.SouthWestTall:
    $Graphics/WallSWTall.visible = true
  
  if facing == Facing.SouthEastTall:
    $Graphics/WallSETall.visible = true


func _process(d: float):
  if not Engine.editor_hint:
    return
  set_wall_vis()
  
