extends Control

var disable_input = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), 3)
	tween.parallel().tween_property($AngelicMusicPlayer, "volume_db", -8, 4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed() -> void:
	if disable_input:
		return
	$ButtonSound.play()
	disable_input = true 
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 1.0), 1)
	tween.parallel().tween_property($AngelicMusicPlayer, "volume_db", -60, 4)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_quit_button_pressed():
	if disable_input:
		return
	$ButtonSound.play()
	await $ButtonSound.finished
	get_tree().quit()


func _on_start_button_mouse_entered():
	$ButtonSound.play()
	pass # Replace with function body.


func _on_quit_button_mouse_entered():
	$ButtonSound.play()
	pass # Replace with function body.
