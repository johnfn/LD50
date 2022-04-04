extends Node2D

func _on_Area_body_entered(body):
  if body == Globals.Player:
    print("enter_stairs")
    var path = self.get_path()
    var regex = RegEx.new()
    regex.compile("\/Level(\\d+)\/") #escaaaaapppeee
    var result = regex.search(path)
    Globals.Player.enter_stairs(int(result.get_string(1)))
