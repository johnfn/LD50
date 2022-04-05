extends Node2D

export var is_on = false
# These are NodePaths
export var linked_doors : Array

# These are Doors
var linked_door_nodes : Array
onready var og_is_on = is_on

var initial_modulate = Color(0.2, 0.2, 0.2, 1.0)

func _ready():
  $Sprite.modulate = initial_modulate
  update_gfx()
  
  for door_path in linked_doors:
    linked_door_nodes.append(get_node(door_path))

# press the switch
func _on_Area_body_entered(body):
  if body == Globals.Player:
    is_on = not is_on
    
    Sfx.play_sound(Sfx.Switch)
    
    var is_now_open = false
    
    for door in linked_door_nodes:
      door.toggle_open()
      is_now_open = door.is_door_open
    
    if is_now_open:
      Sfx.play_sound(Sfx.DoorOpen, true)   
    else:
      Sfx.play_sound(Sfx.DoorClose, true)
         
  update_gfx()
  
func update_gfx():
  $Sprite.visible = not is_on
  $SpritePressed.visible = is_on

func reset():
  is_on = og_is_on
  update_gfx()

# come near the switch
func _on_NearbyArea_body_entered(body):
  $Sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)
  for door in linked_door_nodes:
    door.glow()

func _on_NearbyArea_body_exited(body):
  $Sprite.modulate = initial_modulate
  for door in linked_door_nodes:
    door.glow_stop()
