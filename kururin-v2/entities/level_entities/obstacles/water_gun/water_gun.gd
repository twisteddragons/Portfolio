@tool
extends Node2D

const SPRAY_OFFSET: float = 5.0 ## added to spray length when colliding with player

#@export_tool_button("set_length", "Callable") var foobar = set_length

@export var strength: float = 0.4:
	set(value):
		strength = value
		#material.set_shader_parameter("")
@export_range(0, 1000, 16) var length: float = 64.0:
	set(value):
		length = value
		max_size = length
		set_length()

@onready var push_direction: Vector2 = Vector2(0,1).rotated(rotation)


var max_size: float = length #%WaterMask.size.y

# Called when the node enters the scene tree for the first time.
func _ready():
	set_length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody2D = null
	var distances: Array[float] = []
	
	## UGLY CODE, CLEAN UP.
	## check each raycast for player collision
	if %LeftRayCast2D.is_colliding():
		var object: Node2D = %LeftRayCast2D.get_collider()
		if object.is_in_group("Player"):
			player = object
			var origin: Vector2 = %LeftRayCast2D.global_transform.origin
			var collision_point: Vector2 = %LeftRayCast2D.get_collision_point()
			var distance: float = origin.distance_to(collision_point)
			distances.append(distance)
	if %CenterRayCast2D.is_colliding():
		var object: Node2D = %CenterRayCast2D.get_collider()
		if object.is_in_group("Player"):
			player = object
			var origin: Vector2 = %CenterRayCast2D.global_transform.origin
			var collision_point: Vector2 = %CenterRayCast2D.get_collision_point()
			var distance: float = origin.distance_to(collision_point)
			distances.append(distance)
	if %RightRayCast2D.is_colliding():
		var object: Object = %RightRayCast2D.get_collider()
		if object.is_in_group("Player"):
			player = object
			var origin: Vector2 = %RightRayCast2D.global_transform.origin
			var collision_point: Vector2 = %RightRayCast2D.get_collision_point()
			var distance: float = origin.distance_to(collision_point)
			distances.append(distance)
	
	## Calculate size of water gun based off of collisions
	var distance_avg: float = 0.0
	for distance in distances:
		distance_avg += distance
	
	if distances.size() == 0:
		distance_avg = max_size
	else:
		distance_avg /= distances.size()
		distance_avg += SPRAY_OFFSET
	%EndSpray.position.y = distance_avg
	%WaterMask.size.y = distance_avg
	
	## Push player if colliding
	if player != null:
		player.position += push_direction * strength

func set_length():
	%LeftRayCast2D.target_position.y = length
	%CenterRayCast2D.target_position.y = length
	%RightRayCast2D.target_position.y = length
	%EndSpray.position.y = length
	%WaterMask.size.y = length
