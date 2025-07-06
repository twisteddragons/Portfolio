extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_credits()

func handle_credits():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), 1)
	await get_tree().create_timer(10).timeout
	tween = create_tween()
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 1.0), 1)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
