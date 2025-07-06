class_name Spring
extends Area2D

#signal spring_hit(direction: Vector2, knockback_strength: float, knockback_duration: float,\
	#rot_knockback_strength: float, )

@export var max_knockback_strength: float = 200
@export var min_knockback_strength: float = 100
@export var max_distance: float = 50.0 #TODO: use these
@export var min_distance: float = 0.0
@export var knockback_duration: float = 0.3

@onready var _rotation_unit_vector: Vector2 = Vector2.UP.rotated(rotation)

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_check_for_bodies()
	pass

func _on_body_entered(body):
	if body is Player:
		$AnimationPlayer.play("spring_hit")
		var knockback_strength: float = _calculate_knockback_strength(body.global_position)
		var rot_knockback_strength: float = 2.5
		var reverse_direction: bool = _calculate_reverse_direction(body.global_position, body.rot_dir)
		body.handle_knockback(_rotation_unit_vector, knockback_strength, knockback_duration)
		body.handle_rotation_knockback(rot_knockback_strength, knockback_duration, reverse_direction)
		if reverse_direction:
			body.reverse_spin_direction()

func _check_for_bodies():
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _calculate_knockback_strength(player_position: Vector2) -> float:
	var pq = global_position.direction_to(player_position) ## Vector pointing from spring to player
	var flattened_vector: Vector2 = pq.project(_rotation_unit_vector) ## project pq to get distance of cockpit from spring
	var distance: float = flattened_vector.length() 
	return lerp(max_knockback_strength, min_knockback_strength, distance)

func _calculate_reverse_direction(player_position: Vector2, current_rot_direction: float) -> bool:
	var orth = _rotation_unit_vector.orthogonal() ## rotated 90 deg counter clockwise
	var pq = player_position.direction_to(global_position) ## vector from player to spring
	var dot: float = pq.dot(orth) ## pos if acute, neg if obtuse
	if dot * current_rot_direction <= 0:
		return true
	return false

func _on_timer_timeout():
	_check_for_bodies()
