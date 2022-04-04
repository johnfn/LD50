extends Node

onready var Tick1 = preload("res://audio/sfx/tick1.mp3")
onready var Tick2 = preload("res://audio/sfx/tick2.mp3")

onready var Step1 = preload("res://audio/sfx/step1.mp3")
onready var Step2 = preload("res://audio/sfx/step2.mp3")
onready var Step3 = preload("res://audio/sfx/step3.mp3")

onready var StatueSlide = preload("res://audio/sfx/statue slide.mp3")

onready var Player: AudioStreamPlayer = $"/root/Root/Audio/AudioStreamPlayer"
onready var HighPriorityPlayer: AudioStreamPlayer = $"/root/Root/Audio/AudioStreamPlayerHighPri"

func play_sound(sound, high_priority = false):
  if high_priority:
    HighPriorityPlayer.stream = sound
    HighPriorityPlayer.play()    
  else:
    Player.stream = sound
    Player.play()

func step():
  var steps = [Step1, Step2, Step3]
  var step = steps[randi() % steps.size()]
  
  play_sound(step)
