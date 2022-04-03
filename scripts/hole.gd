extends StaticBody2D

class_name Hole

func fill():
  get_node("Shape").set_deferred("disabled", true)
  visible = false

func reset():
  get_node("Shape").set_deferred("disabled", false)
  visible = true
