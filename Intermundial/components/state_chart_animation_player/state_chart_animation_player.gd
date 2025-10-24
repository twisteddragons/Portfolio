class_name StateChartAnimationPlayer
extends AnimationPlayer

@export var state_chart: StateChart

func _ready():
	animation_started.connect(_on_animation_started)
	animation_finished.connect(_on_animation_finished)

func _on_animation_started(anim_name):
	state_chart.send_event(anim_name + "_started")


func _on_animation_finished(anim_name):
	state_chart.send_event(anim_name + "_finished")
	print(anim_name + "_finished")
