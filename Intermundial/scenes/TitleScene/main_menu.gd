extends Control

func _ready() -> void:
	GlobalMusicController.force_play_track(0)

func _on_new_run_pressed() -> void:
	Global.game_controller.change_3d_scene("uid://d8txut18hr2s") # room generator
	Global.game_controller.remove_gui_scene()
	


func _on_test_world_pressed() -> void:
	Global.game_controller.change_3d_scene("uid://cq805lqhwd3wf") # Main (test scene)
	Global.game_controller.remove_gui_scene()


func _on_settings_pressed() -> void:
	pass # Replace with function body.
