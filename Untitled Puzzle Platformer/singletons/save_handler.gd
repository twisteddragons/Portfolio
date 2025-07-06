extends Node

const SAVE_PATH = "user://File1.data"

static func _static_init() -> void:
	ObjectSerializer.register_script("SaveFile", SaveFile)
	ObjectSerializer.register_script("LevelPlayerData", LevelPlayerData)

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var serialized_save_file: Variant = BinarySerializer.serialize_bytes(GlobalStats.data)
	## TODO: load autosave icon
	file.store_buffer(serialized_save_file)
	file.close()
	#ResourceSaver.save(serialized_save_file, SAVE_PATH)
	## TODO: remove autosave icon

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("no save found")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	var serialized_save_file: Variant = BinarySerializer.deserialize_bytes(file.get_file_as_bytes(SAVE_PATH))
	file.close()
	GlobalStats.data = serialized_save_file

func delete_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("no save found")
		return
	var dir = DirAccess.open("user://")
	dir.remove(SAVE_PATH)
	GlobalStats.data = SaveFile.new()
