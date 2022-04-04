extends Node2D

export var width: float = 128
export var height: float = 128

export var e_occlude = true
export var w_occlude = true
export var n_occlude = true
export var s_occlude = true

func _ready():
  $LightOccluderE.position.x += width - 128
  $LightOccluderS.position.y += height - 128
  $LightOccluderE.scale.y = height / 128
  $LightOccluderW.scale.y = height / 128
  $LightOccluderN.scale.y = width / 128
  $LightOccluderS.scale.y = width / 128

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  $LightOccluderE.visible = e_occlude and Globals.Player.global_position.x < global_position.x + width
  $LightOccluderW.visible = w_occlude and Globals.Player.global_position.x > global_position.x
  $LightOccluderN.visible = n_occlude and Globals.Player.global_position.y > global_position.y
  $LightOccluderS.visible = s_occlude and Globals.Player.global_position.y < global_position.y + height
