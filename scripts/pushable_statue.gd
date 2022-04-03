extends KinematicBody2D

onready var og_position = global_position

func reset():
  global_position = og_position
  get_node("Shape").set_deferred("disabled", false)
  visible = true

func drop_in_hole():
  get_node("Shape").set_deferred("disabled", true)
  visible = false
