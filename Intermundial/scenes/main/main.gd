extends Node3D


func _ready() -> void:
	#MusicController.init(%MusicStreamPlayer)
	#MusicController.set_volume(-14.0)
	#MusicController.random_track()
	
	GlobalMusicController.random_track()
	GlobalMusicController.play_ambience(0)
	
	RespawnManager.kill_floor_distance = %kill_floor.global_position.y

func _input(_event):
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			%SettingsMenu.hide()
		else:
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			%SettingsMenu.show()
		
