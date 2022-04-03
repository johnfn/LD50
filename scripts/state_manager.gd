extends Node

const SAVE_FILE_NAME = "user://checkpoint.save"

var torch_count : int = 0
var seen_torches : bool = false
var spawn_point : Vector2

func checkpoint(new_spawn_point: Vector2):
  torch_count = Globals.num_torches
  seen_torches = Globals.encountered_torches
  spawn_point = new_spawn_point

func return_to_checkpoint():
  for resettable in get_tree().get_nodes_in_group("resettable"):
    resettable.reset()
  Globals.num_torches = torch_count
  Globals.encountered_torches = seen_torches
  
  Globals.Player.respawn(spawn_point)
  
  for shadow_checker in get_tree().get_nodes_in_group("shadow_checker"):
    shadow_checker.update_flood_fill_based_on_player_location()

func save_checkpoint():
  var save_data = {
    "spawn_x": spawn_point.x,
    "spawn_y": spawn_point.y,
    "torch_count": torch_count,
    "seen_torches": seen_torches,
   }
  
  var save_file = File.new()
  save_file.open(SAVE_FILE_NAME, File.WRITE)
  save_file.store_line(to_json(save_data))
  save_file.close()

func load_checkpoint(checkpoint_bytes: PoolByteArray):
  var save_file = File.new()
  if not save_file.file_exists(SAVE_FILE_NAME):
    print("no save file")
    return
  save_file.open(SAVE_FILE_NAME, File.READ)
  var save_data = parse_json(save_file.get_line())
  save_file.close()
  
  spawn_point.x = save_data["spawn_x"]
  spawn_point.y = save_data["spawn_y"]
  torch_count = save_data["torch_count"]
  seen_torches = save_data["seen_torches"]
