extends Node2D

onready var Player = $"/root/Root/AllGameObjects/Player"
onready var UI = $"/root/Root/UI"

var IS_GRANT = OS.has_environment("USER") and (OS.get_environment("USER") in ['arch1', "grant"])

var IS_DEBUG = false
var DEBUG_NO_SHADOWS = IS_DEBUG
var DEBUG_NO_MUSIC = IS_DEBUG

var is_showing_dialog = false
var grid_size = 128
var num_torches = 0
var encountered_torches = false

# 0 is a special value that means to not load in any level.
var current_level = 0

func get_level(which_level):
  var levels = $"/root/Root/AllGameObjects/Levels".get_children()

  for i in range(len(levels)):
    if levels[i].name != "Level" + str(i + 1):
      print("Levels in 'Levels' node at %d are out of order/missing!" % (i))

  return levels[which_level - 1]

func game_mode():
  if is_showing_dialog:
    return "dialog"

  return "normal"
