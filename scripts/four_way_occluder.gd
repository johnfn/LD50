extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  for thing in get_children():
    if thing is LightOccluder2D:
      var occ: LightOccluder2D = thing
      
      occ.visible = true
  
  if Globals.Player.global_position.x > $LightOccluderW.global_position.x:
    $LightOccluderE.visible = false
  if Globals.Player.global_position.x < $LightOccluderE.global_position.x:
    $LightOccluderW.visible = false
  
  if Globals.Player.global_position.y < $LightOccluderS.global_position.y:
    $LightOccluderN.visible = false
    
  if Globals.Player.global_position.y > $LightOccluderN.global_position.y:
    $LightOccluderS.visible = false
