extends Area2D

func _on_Checkpoint_body_entered(body):
  if body == Globals.Player:
    StateManager.checkpoint($SpawnPoint.global_position)
