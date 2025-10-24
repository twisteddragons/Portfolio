extends Node3D

const SPEED = 40.0

@onready var projectile_col: RayCast3D = $projectile_col



func _process(delta):
	position += transform.basis * Vector3(0,0, - SPEED) * delta


func _on_cleanup_timer_timeout() -> void:
	queue_free()
