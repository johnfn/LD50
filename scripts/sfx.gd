extends Node

onready var Tick1 = preload("res://audio/sfx/tick1.mp3")
onready var Tick2 = preload("res://audio/sfx/tick2.mp3")

onready var Player: AudioStreamPlayer = $"/root/Root/AudioStreamPlayer"

func play_sound(sound):
  Player.stream = sound
  Player.play()
