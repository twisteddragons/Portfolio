extends Node3D

@export var voicelines : Array[Resource] = []

var can_play_voiceline : bool = false

@onready var voiceline_player: AudioStreamPlayer3D = $voiceline_player
@onready var voiceline_cooldown: Timer = $voiceline_cooldown

func _ready() -> void:
	can_play_voiceline = true
	_on_voiceline_player_finished()

#plays a random voiceline from array
func play_random_voiceline():
	var random_voiceline = voicelines[randi_range(0, voicelines.size()-1)]
	voiceline_player.stream = random_voiceline
	voiceline_player.play()

#generates cooldown after voiceline finished
func _on_voiceline_player_finished() -> void:
	voiceline_cooldown.wait_time = randf_range(10.0, 30.0)
	voiceline_cooldown.start()


func _on_timer_timeout() -> void:
	play_random_voiceline()
