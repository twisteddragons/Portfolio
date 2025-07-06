extends Node2D

@export var min_pull_strength: float = 0.0
@export var max_pull_strength: float = 0.1


@export var rotation_strength: float = 1.0

@export var clockwise: bool = true

@onready var max_pull_distance: float = $Area2D/CollisionShape2D.shape.radius * scale.x

# Called when the node enters the scene tree for the first time.
func _ready():
	print(max_pull_distance)
	var rotation_direction: float = 1
	if !clockwise:
		rotation_direction = -1
	$ColorRect.material.set_shader_parameter("direction", rotation_direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for object in $Area2D.get_overlapping_bodies():
		if object.is_in_group("Player"):
			var player_global_position: Vector2 = object.transform.origin
			var pull_strength: float = get_pull_strength_at_point(player_global_position)
			var pull_direction: Vector2 = (global_transform.origin - player_global_position).normalized()
			var rotation_direction: Vector2 = get_rotation_at_point(player_global_position)
			object.position += pull_direction * lerp(min_pull_strength, max_pull_strength, pull_strength)\
				+ rotation_direction * rotation_strength

## returns percentage of how much strength to pull object, can go above 1.0
func get_pull_strength_at_point(point: Vector2) -> float:
	var vector_to_point: Vector2 = (point - global_transform.origin)
	var distance: float = vector_to_point.length()
	return distance/max_pull_distance

##returns the direction an object would move at a given GLOBAL point to the whirlpool
func get_rotation_at_point(point: Vector2) -> Vector2:
	var direction: int = 1
	if !clockwise:
		direction = -1
	
	var vector_to_point: Vector2 = (global_transform.origin - point).normalized()
	var move_direction = vector_to_point.rotated((PI/2) * direction)
	return move_direction
