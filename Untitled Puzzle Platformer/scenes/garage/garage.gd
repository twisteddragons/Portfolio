extends Control

@export var pan_duration: float = 2.5

var translate_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in %Cockpits.get_children():
		child.cockpit_chosen.connect(%Player.set_cockpit)

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

func translate(final_position: Vector2, ease: Tween.EaseType):
	if translate_tween and translate_tween.is_running():
		return
	
	translate_tween = get_tree().create_tween()
	translate_tween.tween_property(self, "position", final_position, pan_duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_BACK)


func _on_back_button_pressed():
	translate(Vector2(size.x, 0), Tween.EASE_IN)
