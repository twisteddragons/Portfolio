extends Node

## Redo / remove this at some point

@onready var shatter_effect: AnimatedSprite2D = $AnimatedSprite2D

@onready var crosshair: Node2D = $crosshair
@onready var shatter_sfx: AudioStreamPlayer = $shatter_sfx

@onready var loading_screen = load("uid://dhvr1bhu5bmj1")
var shatter_ready : bool = false
var shattered : bool = false



func _input(event):
	if Input.is_action_just_pressed("debug_tab"):
		targeting()
	if Input.is_action_just_pressed("shoot"):
		if shatter_ready and ! shattered:
			shatter()



func targeting():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	crosshair.visible = true
	shatter_ready = true
	

func shatter():
	shattered = true
	shatter_sfx.play()
	GlobalMusicController.stop_track()
	crosshair.visible = false
	shatter_effect.visible = true
	shatter_effect.play("default")
	GlobalMusicController.force_play_track(-1)
	
	await get_tree().create_timer(2.0).timeout
	print("finished")
	
	Global.game_controller.change_gui_scene("uid://dhvr1bhu5bmj1")
	Global.game_controller.remove_3d_scene()
