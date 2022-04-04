extends Node2D

onready var label = $DialogUpscaler/Rect/Label
onready var rect = $DialogUpscaler/Rect
onready var xbutton = $DialogUpscaler/XButton

var max_width = 400
var text_speed = 2 # smaller = faster
var is_showing_dialog = false

func resize_img():
  var visible_text = label.text.substr(0, label.visible_characters)
  
  var rect_size_oneline = label.get_font("normal_font").get_string_size(visible_text)
  var new_rect_size = label.get_font("normal_font").get_wordwrap_string_size(visible_text, max_width)
  
  new_rect_size.x = min(rect_size_oneline.x, new_rect_size.x)
  rect.rect_size = new_rect_size + Vector2(16, 16)
  
  xbutton.rect_position.x = rect.rect_position.x + rect.rect_size.x - 20
  xbutton.rect_position.y = rect.rect_position.y + rect.rect_size.y - 20

func show_dialog_co(text_to_show: String):
  if Globals.is_showing_dialog:
    return
    
  visible = true
  
  Globals.is_showing_dialog = true
  
  var skip = false
  
  for text_len in range(text_to_show.length()):
    label.text = text_to_show
    label.visible_characters = text_len
    
    resize_img()
    
    for x in range(text_speed):
      yield(get_tree(), "idle_frame")
    
      if Input.is_action_just_pressed("interact"):
        skip = true
        break
    
    if skip:
      break
  
  yield(get_tree(), "idle_frame")
  
  label.visible_characters = text_to_show.length()
  resize_img()
  
  while true:
    yield(get_tree(), "idle_frame")
    
    if Input.is_action_just_pressed("interact"):
      break
    
  self.visible = false
  
  Globals.is_showing_dialog = false
