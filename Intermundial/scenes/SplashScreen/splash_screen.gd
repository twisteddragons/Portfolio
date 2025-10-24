extends Control


func _ready() -> void:
	GlobalMusicController.play_ambience(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		Global.game_controller.change_gui_scene("res://scenes/TitleScene/MainMenu.tscn", true)
