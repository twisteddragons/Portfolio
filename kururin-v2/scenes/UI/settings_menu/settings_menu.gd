extends Control

var resolutions = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600),
	"640x360": Vector2i(640,360)
}

var reading_keybind_input: bool = false ## true after pressing a keybind button
var input_map_key: String ## contains key of action to put data in
var reading_keybind_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	add_resolutions()
	init_values()

# if the previous scene passed any data, it will get received here
func receive_data(data):
	print(data)
	

# Called after scene receives data, before start_scene. The loading screen is still present at this point
func init_scene():
	pass 

# Called after init_scene. The loading screen is gone at this point
func start_scene(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent):
	if !reading_keybind_input:
		return

	if event is InputEventKey:
		# Save new binding in settings
		SettingsHandler.save_keybind_setting(input_map_key, event)
		
		# Set new binding right now
		InputMap.action_erase_events(input_map_key) ## Clear any existing events
		InputMap.action_add_event(input_map_key, event)
		
		# disable keybind reading mode
		reading_keybind_button.text = event.as_text()
		reading_keybind_input = false

## Adds all the different resolution options
func add_resolutions():
	%ResolutionDropdown.clear()
	for r in resolutions:
		%ResolutionDropdown.add_item(r)

## sets all values to the ones in the settings file
func init_values():
	## Keybind settings
	for keybind_button: Button in get_tree().get_nodes_in_group("KeybindingButton"):
		var key = keybind_button.action
		if InputMap.has_action(key):
			var action = SettingsHandler.config.get_value("keybindings", key)
			keybind_button.text = action.as_text()
		else:
			keybind_button.text = "ERROR: couldn't read keybind"
	
	## Video settings
	var resolution: Vector2i = SettingsHandler.config.get_value("video", "resolution")
	%ResolutionDropdown.selected = resolutions.keys().find(str(resolution.x, "x", resolution.y))
	var fullscreen: bool =  SettingsHandler.config.get_value("video", "fullscreen")
	%FullscreenCheckButton.button_pressed = fullscreen
	
	## Audio settings
	%MasterVolumeSlider.set_value_no_signal(SettingsHandler.config.get_value("audio", "master_volume"))
	%MusicVolumeSlider.set_value_no_signal(SettingsHandler.config.get_value("audio", "music_volume"))
	%SFXVolumeSlider.set_value_no_signal(SettingsHandler.config.get_value("audio", "sfx_volume"))

func _on_master_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	SettingsHandler.save_audio_setting("master_volume", value)


func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	SettingsHandler.save_audio_setting("music_volume", value)


func _on_sfx_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	SettingsHandler.save_audio_setting("sfx_volume", value)


func _on_resolution_dropdown_item_selected(index):
	var key: String = %ResolutionDropdown.get_item_text(index)
	
	get_window().set_size(resolutions[key])
	SettingsHandler.save_video_setting("resolution", resolutions[key])


func _on_fullscreen_check_button_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		%ResolutionDropdown.disabled = true
		var monitor_size: Vector2i = DisplayServer.screen_get_size()
		%ResolutionDropdown.selected = resolutions.keys().find(str(monitor_size.x, "x", monitor_size.y))
		## TODO: might break with multiple windows at different resolutions?
		get_window().set_size(monitor_size)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		%ResolutionDropdown.disabled = false
		var resolution: Vector2i = SettingsHandler.config.get_value("video", "resolution")
		get_window().set_size(resolution)
		%ResolutionDropdown.selected = resolutions.keys().find(str(resolution.x, "x", resolution.y))
	SettingsHandler.save_video_setting("fullscreen", toggled_on)

## Enable rebinding mode for the given button/action
func _on_keybind_button_pressed(source: Button, action: String):
	if reading_keybind_input == false:
		reading_keybind_input = true
		reading_keybind_button = source
		source.text = "press a button dummy!"
		input_map_key = action


func _on_back_button_pressed():
	hide()
