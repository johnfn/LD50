extends CanvasLayer

func _process(_delta):
  $TorchDisplay.visible = Globals.encountered_torches
  $TorchDisplay/Count.text = "x" + str(Globals.num_torches)
