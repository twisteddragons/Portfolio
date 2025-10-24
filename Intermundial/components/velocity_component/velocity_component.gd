class_name VelocityComponent
extends Node3D

@export var max_speed: float = 5
@export var acceleration_coefficient: float = 1
@export var jump_strength: float = 5

## if true: this velocity component's parent will use this velocity to move
@export var apply_to_parent: bool = true
@export var affected_by_gravity: bool = true

## flying enemy properties
@export var is_flying: bool = false
@export var hover_height: float = 3.0
@export var height_adjust_speed: float = 3.0
@export var ground_raycast: RayCast3D

var velocity: Vector3 = Vector3.ZERO
var target_velocity: Vector3 = Vector3.ZERO
var gravity_strength: float = 0.0
var speed_multiplier: float = 1
var acceleration_coefficient_multiplier: float = 1
var ground_plane: Plane = Plane.PLANE_XZ

##flying specific
var vertical_velocity: float = 0.0
var collision_point

var actor: CharacterBody3D = null
var movement_disabled: bool = false

var speed_percent: float:
	get:
		return velocity.length()/max_speed
var calculated_max_speed: float:
	get:
		return max(max_speed * speed_multiplier, 0)

func _ready():
	if apply_to_parent:
		actor = get_parent().get_parent()
	
	if is_flying and actor:
		setup_flying_raycast()

## set raycast to proper hight
func setup_flying_raycast():
	ground_raycast.target_position = Vector3.DOWN * (hover_height)

func _physics_process(delta):
	
	velocity = velocity.move_toward(target_velocity, acceleration_coefficient * acceleration_coefficient_multiplier * delta)
	
	if actor:
		var final_velocity: Vector3 = velocity
		
		if affected_by_gravity and !is_flying:
			ground_plane = Plane(actor.get_gravity().normalized())
			final_velocity = ground_plane.project(final_velocity) #Project movement onto ground plane
			if not actor.is_on_floor():
				gravity_strength += actor.get_gravity().length() * delta
			else:
				gravity_strength = 0
			final_velocity += gravity_strength * ground_plane.normal
		#flying logics
		elif is_flying:
			if ground_raycast.is_colliding():
				final_velocity.y += height_adjust_speed
		
		actor.velocity = final_velocity
		
		if movement_disabled:
			actor.velocity = Vector3.ZERO
		
		actor.move_and_slide()

func get_max_velocity(direction: Vector3) -> Vector3:
	return direction * calculated_max_speed

func accelerate_to_velocity(desired_velocity: Vector3) -> void:
	velocity = velocity.move_toward(desired_velocity, acceleration_coefficient * acceleration_coefficient_multiplier)# lerp(desired_velocity, 0.1) ## TODO: find acceleration function that feels good

func accelerate_in_direction(direction: Vector3) -> void:
	direction = direction.normalized()
	accelerate_to_velocity(get_max_velocity(direction))

func maximize_velocity(direction: Vector3) -> void:
	velocity = get_max_velocity(direction)

func decelerate() -> void:
	accelerate_to_velocity(Vector3.ZERO)

#instant stop
func stop():
	velocity = Vector3.ZERO

func jump():
	if affected_by_gravity and !is_flying:
		velocity += actor.get_gravity().normalized() * jump_strength

func move(character: CharacterBody3D) -> void:
	character.velocity = velocity
	character.move_and_slide()

func remove_actor(keep_velocity: bool = false) -> void:
	if !keep_velocity:
		actor.velocity = Vector3.ZERO
	actor = null

###flying funtionality
### this isnt working fully as intended, the enemy should favor the hover height but should freely be able to accend if the player is above them
#func adjust_flying_height(delta):
	#if ground_raycast and ground_raycast.is_colliding():
		#collision_point = ground_raycast.get_collision_point()
		#var desired_height = collision_point.y + hover_height 
		#var current_y = actor.global_position.y
		#
		## smoothly transition to desired height
		#var new_y = lerp(current_y, desired_height, height_adjust_speed * delta)
		#
		## calculate velocity needed
		#vertical_velocity = (new_y - current_y) / delta
		#
	##else: # if no raycast collison move down
		##actor.velocity.y = -height_adjust_speed

##flying funtionality
## this isnt working fully as intended, the enemy should favor the hover height but should freely be able to accend if the player is above them
#func adjust_flying_height(delta):
	##if ground_raycast and ground_raycast.is_colliding():
#
	#
		#var desired_height = collision_point.y + hover_height 
		#var current_y = actor.global_position.y
		#
		## smoothly transition to desired height
		#var new_y = lerp(current_y, desired_height, height_adjust_speed * delta)
		#
		## calculate velocity needed
		#vertical_velocity = (new_y - current_y) / delta
		#
	##else: # if no raycast collison move down
		##actor.velocity.y = -height_adjust_speed
