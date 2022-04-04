extends Area2D

export var dialog_name = ""
var triggered_dialogs = {}

func _on_DialogTrigger_body_entered(body):
  if body == Globals.Player and not dialog_name in triggered_dialogs:
    triggered_dialogs[dialog_name] = true
    
    Globals.Player.start_dialog_co(dialog_name)

func reset():
  pass
  # triggered_dialogs = {}
