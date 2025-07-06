class_name LoadingScreen
extends CanvasLayer

signal transition_in_complete()

const DEFAULT_LIBRARY = "fade"
const START_SUFFIX = "in"
const END_SUFFIX = "out"

var next_screen : String = "uid://pk6fkc54dama"
var chosen_animation_library : String = "fade"

@onready var progress_bar : ProgressBar = $Control/ProgressBar
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer

func _ready():
	progress_bar.visible = false
	#ResourceLoader.load_threaded_request(next_screen)

func _process(delta):
	pass

func start_transition(library_name : String):
	# check that IN animation exists
	if !anim_player.has_animation_library(library_name) or !anim_player.has_animation(chosen_animation_library + "/" + START_SUFFIX):
		library_name = DEFAULT_LIBRARY
		
	chosen_animation_library = library_name
	anim_player.play(chosen_animation_library + "/" + START_SUFFIX)
	
	# start timer to show progress bar if loading takes long enough
	timer.start()

func finish_transition() -> void:
	if timer:
		timer.stop()
	
	# check that OUT animation exists
	if !anim_player.has_animation_library(chosen_animation_library) or !anim_player.has_animation(chosen_animation_library + "/" + END_SUFFIX):
		chosen_animation_library = DEFAULT_LIBRARY
	
	anim_player.play(chosen_animation_library + "/" + END_SUFFIX)
	
	# wait until animation is done before freeing self
	await anim_player.animation_finished
	queue_free()

# called when screen is totally obscured so the scene manager can start loading the next scene
func report_midpoint() -> void:
	transition_in_complete.emit()

func update_progress(progress : float):
	progress_bar.value = progress

func _on_timer_timeout() -> void:
	progress_bar.visible = true
