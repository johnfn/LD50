extends Node2D

onready var label = $InteractionHint/TextUpscaler/Rect/Label
onready var rect = $InteractionHint/TextUpscaler/Rect
onready var animation = $InteractionHint/Animation

export var interaction_name: String = "hello"

var margin = Vector2(32, 16)
var interacted = false

func _ready():
  reset()

func reset():
  visible = false
  animation.play("Default")

func can_interact():
  return visible and not interacted

func interact():
  interacted = true

  animation.play("Interact")
  yield(animation, "animation_finished")
  
  visible = false


func _on_Area2D_body_entered(body):
  if body != Globals.Player or interacted:
    return
  
  animation.stop()
  
  animation.play("Default")
  yield(animation, "animation_finished")
  
  visible = true
  
  $"../Animation".play("Glow")
  show_text_co(interaction_name)

func show_text_co(text: String):  
  label.text = text
  
  for i in range(len(label.text)):
    var visible_text = text.substr(0, i)
    label.visible_characters = i
    
    var rect_size_oneline = label.get_font("font").get_string_size(visible_text)
  
    rect.rect_size = Vector2(rect_size_oneline + margin)
    
    for x in range(3):
      yield(get_tree(), "idle_frame")

func _on_Area_body_exited(body):
  if body != Globals.Player or interacted:
    return
    
  animation.play("Default")
  yield(animation, "animation_finished")

  animation.play("Fade")
  yield(animation, "animation_finished")
  
  $"../Animation".play("RESET")
  visible = false
