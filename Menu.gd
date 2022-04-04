extends Control

var time = 0
var amplitude = 0.05
onready var ogscale = $TextureRect2.rect_scale

func _ready():
  Sfx.play_song("menu")

func _physics_process(delta):
  time += delta
  var scaleamt = 1 + (sin(time) - 1) * amplitude
  $TextureRect2.rect_scale = scaleamt * ogscale

func _input(event):
  if event is InputEventMouseButton:
    if event.pressed and event.button_index == 1:
      Globals.started = true
      Sfx.play_song("level")
      queue_free()
