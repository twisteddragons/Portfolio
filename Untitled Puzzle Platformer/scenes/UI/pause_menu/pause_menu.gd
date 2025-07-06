extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resume_pressed():
	hide()
	get_tree().paused = false


func _on_view_map_pressed():
	pass # Replace with function body.

#restart the current level
func _on_restart_pressed():
	#get_tree().paused = false 
	#get_tree().reload_current_scene()
	SceneManager.restart_scene()

#exits level to level select
func _on_quit_pressed():
	get_tree().paused = false 
	#SceneManager.switch_scene(preload("res://Scenes/levelSelect.tscn"))


#ensure the resume button has focus when paused
func _on_visibility_changed():
	if visible:
		$VBoxContainer/Resume.grab_focus()
