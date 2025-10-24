extends Node

const SETTINGS_PATH = "user://settings.ini"
var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if !FileAccess.file_exists(SETTINGS_PATH):
		for action in InputMap.get_actions():
			if !action.begins_with("ui_"): # scuffed filtering for built in godot input maps
				config.set_value("keybindings", action, InputMap.action_get_events(action))
		#config.set_value("keybindings", "left", InputMap.action_get_events("left")[0])
		#config.set_value("keybindings", "right", InputMap.action_get_events("right")[0])
		#config.set_value("keybindings", "forward", InputMap.action_get_events("forward")[0])
		#config.set_value("keybindings", "back", InputMap.action_get_events("back")[0])
		#config.set_value("keybindings", "jump", InputMap.action_get_events("jump")[0])
		#config.set_value("keybindings", "shoot", InputMap.action_get_events("shoot")[0])
		#config.set_value("keybindings", "kick", InputMap.action_get_events("kick")[0])
		#config.set_value("keybindings", "reload", InputMap.action_get_events("reload")[0])
		#config.set_value("keybindings", "esc", InputMap.action_get_events("esc")[0])
		#config.set_value("keybindings", "interact", InputMap.action_get_events("interact")[0])
		
		config.set_value("video", "fullscreen", true)
		config.set_value("video", "resolution", Vector2i(1920, 1080))
		
		config.set_value("audio", "master_volume", 0.7)
		config.set_value("audio", "music_volume", 0.7)
		config.set_value("audio", "sfx_volume", 0.7)
		
		config.save(SETTINGS_PATH)
	else:
		config.load(SETTINGS_PATH)
	apply_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply_settings():
	## Keybind settings
	var keys = config.get_section_keys("keybindings")
	
	for key in keys:  ## key is "up", "down" etc..
		InputMap.action_erase_events(key) ## Clear any existing events
		for event in config.get_value("keybindings", key):
			InputMap.action_add_event(key, event)

		#for action in config.get_value("keybindings", key):
		#	InputMap.action_add_event(key, action)
		#pass
		#InputEventKey.new()
		#var e = InputEventAction.new()
		#InputMap.action_get_events(key)
		#e.set()
		#InputMap.load_from_project_settings()
	
	## Video settings
	if config.get_value("video", "fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_window().set_size(config.get_value("video", "resolution"))
	
	## Audio settings
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(config.get_value("audio", "master_volume")))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(config.get_value("audio", "music_volume")))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(config.get_value("audio", "sfx_volume")))

func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_PATH)

func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_PATH)

func save_keybind_setting(key: String, value):
	var bindings: Array = config.get_value("keybindings", key)
	for i in bindings.size():
		if bindings[i] is InputEventKey:
			bindings[i] = value
	config.set_value("keybindings", key, bindings)
	config.save(SETTINGS_PATH)

#func load_settings():
	#if not ResourceLoader.exists(SETTINGS_PATH):
		#print("no settings found")
		#return
	#GlobalStats.data = load(SETTINGS_PATH)
