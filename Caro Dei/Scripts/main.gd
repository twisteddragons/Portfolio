extends Node2D

var ready_to_quit: bool = false
@onready var quit_text: Label = $Player/Label
# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_property($AudioStreamPlayerRain, "volume_db", -3, 5)
	Dialogic.start("intro")
	Dialogic.signal_event.connect(set_rain_volume)

func set_rain_volume(params) -> void:
	var tween = create_tween()
	tween.tween_property($AudioStreamPlayerRain, "volume_db", params["volume"], 8)

func handle_quit_label():
	ready_to_quit = true
	quit_text.visible = true
	await get_tree().create_timer(5).timeout
	ready_to_quit = false
	quit_text.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !ready_to_quit:
			handle_quit_label()
		else:
			get_tree().quit()
