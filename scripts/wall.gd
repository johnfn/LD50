tool
extends Node2D

enum Facing {
  North,
  East,
  South,
  West,
  
  EastTall,
  WestTall,
  
  SouthWest,
  SouthEast,
  
  SouthEastTall,
  SouthWestTall,
}

export(Facing) var facing = Facing.North

func _ready():
  set_wall_vis()

func set_wall_vis():
  for child in $Graphics.get_children():
    child.visible = false
  
  if facing == Facing.North or facing == Facing.South:
    $Graphics/WallN.visible = true
  if facing == Facing.East:
    $Graphics/WallE.visible = true
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
  if facing == Facing.SouthWest:
    $Graphics/WallSW.visible = true
  if facing == Facing.SouthEast:
    $Graphics/WallSE.visible = true


func _process(d: float):
  set_wall_vis()
