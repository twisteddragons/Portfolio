extends Node3D

@export var player : PackedScene

func _ready() -> void:
	get_parent()
	var spawned_player = player.instantiate()
	var scene_root = get_parent().get_parent()
	scene_root.add_child(spawned_player)
	spawned_player.global_position = self.global_position
	RespawnManager.last_active_checkpoint = self
