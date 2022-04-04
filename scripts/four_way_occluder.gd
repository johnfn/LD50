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
  if not e_occlude:
    $LightOccluderE.queue_free()
  if not s_occlude:
    $LightOccluderS.queue_free()
  if not n_occlude:
    $LightOccluderN.queue_free()
  if not w_occlude:
    $LightOccluderW.queue_free()

