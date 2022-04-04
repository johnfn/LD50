extends Node

onready var Tick1 = preload("res://audio/sfx/tick1.mp3")
onready var Tick2 = preload("res://audio/sfx/tick2.mp3")

onready var Step1 = preload("res://audio/sfx/step1.mp3")
onready var Step2 = preload("res://audio/sfx/step2.mp3")
onready var Step3 = preload("res://audio/sfx/step3.mp3")

onready var Switch = preload("res://audio/sfx/switch.mp3")

onready var Chest = preload("res://audio/sfx/chest.mp3")
onready var PickupLantern = preload("res://audio/sfx/lantern_up.mp3")
onready var DropLantern = preload("res://audio/sfx/lantern_down.mp3")

onready var VoiceClara = preload("res://audio/sfx/voice-clara.mp3")
onready var PopDialogEnd = preload("res://audio/sfx/pop-dialog-end.mp3")


onready var Blob1 = preload("res://audio/sfx/blob1.mp3")

onready var StatueSlide = preload("res://audio/sfx/statue slide.mp3")

onready var MenuMusic = preload("res://audio/bgm/menu_music.mp3")
onready var LevelMusic = preload("res://audio/bgm/level_music.mp3")
onready var EndMusic = preload("res://audio/bgm/floor_8_music.mp3")

onready var Player: AudioStreamPlayer = $"/root/Root/Audio/AudioStreamPlayer"
onready var HighPriorityPlayer: AudioStreamPlayer = $"/root/Root/Audio/AudioStreamPlayerHighPri"
onready var BgmPlayer: AudioStreamPlayer = $"/root/Root/Audio/BgmPlayer"

var curr_song = ""
func play_song(song):
  if Globals.DEBUG_NO_MUSIC:
    return
  if song == curr_song:
    return
  if song == 'menu':
    BgmPlayer.stream = MenuMusic
    BgmPlayer.play()
  if song == 'end':
    BgmPlayer.stream = EndMusic
    BgmPlayer.play()
  if song == 'level':
    BgmPlayer.stream = LevelMusic
    BgmPlayer.play()

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
