class_name Player
extends CharacterBody3D

signal health_changed(new_health: int)
signal fire_weapon()
signal jump()
signal reload()
signal reshuffle_ammo()
signal player_action_released_fire


# Physics junk
const ACCELERATION			:float = 15.0
const AIR_ACCELERATION		:float = 5.0
const FRICTION				:float = 30.0
const EXTERNAL_FORCE_DAMP	:float = 0.85
const PULL_FORCE			:float = 10.0

#TODO: this should 100% be in a settings file
const SENSITIVITY:float = 0.001
const CONTROLLER_SENSITIVITY: float = 0.05

 #Headboby
#const BOB_FREQ		:float = 3.0
#const BOB_AMP		:float = 0.08
#var t_bob			:float = 0.0
#var previous_bob_y  :float = 0.0

#take damage effects
#const DAMAGE_SHAKE_STRENGTH	:float = 1.4
#const DAMAGE_SHAKE_DURATION	:float = 0.3
#const VIGNETTE_DURATION		:float = 0.3
#var shake_intensity			:float = 1.0
#var trauma						:float = 1.0
#var original_camera_pos		:Vector3

# Other config
const CLUSTER_HITSCAN_RAYCAST_NUMBER:int = 15
const GUN_LENGTH:float = 0.5

@export var max_health	:int = 100

@export_group("Movement Stats")
@export var jump_strength		:float = 7
@export var bhop				:bool = true
@export_subgroup("Ground Physics")
@export var walk_speed			:float = 10.0
@export var ground_acceleration	:float = 15.0
@export var ground_decceleration:float = 10.0
@export var ground_friction		:float = 6.0
@export_subgroup("Air Physics (careful here)")
@export var air_cap				:float = 0.85
@export var air_acceleration	:float = 800.0
@export var air_move_speed		:float = 500.0

@export_group("Gun Configuration")
@export var fire_rate:float = 0.30  # Seconds between shots

## Physics
var wish_dir:Vector3 = Vector3.ZERO
var _cur_controller_look = Vector2()

## all knockback from external forces will be stored here
var knockback		:Vector3 = Vector3.ZERO
var picked_object	:Node3D
var fire_cooldown	:float = 0.0

## refs
@onready var sound_manager: SoundEffectManager = %sound_manager
@onready var yeehaw: Node3D = $YEEHAW

@onready var health		:int = max_health
@onready var camera		:Camera3D = %Camera
@onready var interaction:RayCast3D = %interaction
@onready var hand		:Marker3D = %grab_point

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for i in range(CLUSTER_HITSCAN_RAYCAST_NUMBER):
		%cluster_raycasts.add_child($Head/Camera/bullet_raycast.duplicate())
	setup_projectile_raycast()

func setup_projectile_raycast() -> void:
	## TODO: Need to adjust Guntip for different resolutions
	var v:Vector3 = %Camera.project_position(%Guntip.position, 0)
	v *= 0.018
	v.y -= 0.05
	v.z = -1.3*GUN_LENGTH
	%projectile_raycast.position += v

func get_facing_direction() -> Vector3:
	return %Camera.global_basis.z
	
func _process(delta):
	#_handle_controller_look_input(delta)
	# Fire cooldown
	if fire_cooldown > 0:
		fire_cooldown -= delta
	
	#footsteps
	if velocity.length() != 0:
		if is_on_floor():
			sound_manager.play_footstep()
	
	# check for killfloor
	if global_position.y < RespawnManager.kill_floor_distance:
		respawn_at_last_checkpoint()

# Smooth controller look
#func _handle_controller_look_input(delta):
	#var target_look = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	#if target_look.length() < _cur_controller_look.length():
		#_cur_controller_look = target_look
	#else:
		#_cur_controller_look = _cur_controller_look.lerp(target_look, 8.0*delta)
	#rotate_y(-_cur_controller_look.x * CONTROLLER_SENSITIVITY)
	#%Camera.rotate_x(_cur_controller_look.y * CONTROLLER_SENSITIVITY)
	#%Camera.rotation.x - clamp(%Camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

## Helps prevent player from clipping. Also enables surf ;)
func clip_velocity(normal:Vector3, overbounce:float, delta:float) -> void:
	# How much we need to push the player away from the wall
	var backoff:float = velocity.dot(normal) * overbounce
	if backoff >= 0: return
	var change:Vector3 = normal * backoff
	velocity -= change
	#Second check
	var adjust:float = velocity.dot(normal)
	if adjust < 0.0:
		velocity -= normal * adjust

## Only to improve surfing
func is_surface_too_steep(normal:Vector3) -> bool:
	var max_slope_ang_dot = Vector3.UP.rotated(Vector3(1.0,0,0), self.floor_max_angle).dot(Vector3.UP)
	if normal.dot(Vector3.UP) < max_slope_ang_dot:
		return true
	return false

func _handle_ground_physics(delta) -> void:
	## TODO: Sprint?
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = walk_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_acceleration * delta * walk_speed
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir
	# Friction
	var control = max(velocity.length(), ground_decceleration)
	var drop = control * ground_friction * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		new_speed /= velocity.length()
	velocity *= new_speed

func _handle_air_physics(delta) -> void:
	velocity.y += get_gravity().y * delta
	## Quake/Half-life-esque strafing
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_acceleration * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir
	
	# Enable surf (and reduce clipping)
	if is_on_wall():
		## Switch mode to reduce jitters while surfing
		if is_surface_too_steep(get_wall_normal()):
			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1, delta)

func _physics_process(delta: float) -> void:
	## Movement physics (https://www.youtube.com/watch?v=ZJr2qUrzEqg)
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") or (bhop and Input.is_action_pressed("jump")):
			jump.emit()
			velocity.y = jump_strength
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	move_and_slide()
	
	# hedbobby
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#var bob_offset = _headbob(t_bob)
	#camera.transform.origin = bob_offset
	
	## picked up phys obj
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		var c = a.distance_to(b)
		var calc = (a.direction_to(b))*PULL_FORCE*c
		picked_object.set_linear_velocity(calc)
	
	## this is setting player position for our invis wall shaders
	RenderingServer.global_shader_parameter_set("player_pos",self.position)



func _input(event) -> void:
	if Input.is_action_just_pressed("interact"):
		var collider = interaction.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact()
		if picked_object == null:
			pickup_object()
		elif picked_object != null:
			drop_object()
	## TODO Move this to _unhandled_input so UI can still be interacted with?
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY) ## TODO: Some kind of debuff effect that inverts these?
		%Camera.rotate_x(-event.relative.y * SENSITIVITY)
		%Camera.rotation.x = clamp(%Camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	#if Input.is_action_just_pressed("YeehawMode"):
		#if ! yeehaw:
			#yeehaw.yeehaw_mode()
		#else:

	
	if Input.is_action_just_pressed("esc"):
		pause()

	## Weapon input
	# Fire
	if event.is_action_pressed("shoot"):
		if fire_cooldown <= 0.0:
			if %weapon_manager.try_fire():
				fire_cooldown = fire_rate
			%weapon_manager.next_chamber()
	if event.is_action_released("shoot"):
		# Ideally, roll cylinder to the next bullet
		# %weapon_manager.next_chamber()
		# This rolls even if the current bullet has not been fired
		emit_signal("player_action_released_fire")
		pass
	
	# Reload
	if event.is_action_pressed("reload"):
		%weapon_manager.try_reload()
	
	# Debug
	if event.is_action_pressed("debug_1"):
		%weapon_manager.debug_1()
	if event.is_action_pressed("debug_2"):
		%weapon_manager.debug_2()
	if event.is_action_pressed("debug_3"):
		%weapon_manager.debug_3()
	
	# Cylinder cycling with scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			%weapon_manager.previous_chamber()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			%weapon_manager.next_chamber()


# respawn player at last checkpoint when fall
func respawn_at_last_checkpoint():
	global_position = RespawnManager.last_active_checkpoint.global_position




# call this for heals
func heal(_amount: int) -> void:
	#health = min(health + amount, 100)
	#health_changed.emit(health)
	pass


func apply_knockback(direction: Vector3, strength: float):
	knockback += direction * strength


#NOTE/TODO: this shouldn't really be handled by the player
func pause():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#get_tree().paused = true



## Picking up/dropping object
func pickup_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		print("object detected:", collider)
		picked_object = collider

func drop_object():
	if picked_object!=null:
		picked_object = null

# Headbob
#func _headbob(time) -> Vector3:
	#var pos = Vector3.ZERO
	#pos.y = sin(time * BOB_FREQ) * BOB_AMP
	#pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP * 0.5
	#return pos

func take_damage(damage) -> void:
	sound_manager.play_sound(03)
	health_changed.emit(health)
	%HealthComponent.damage(damage)

func _on_health_component_died() -> void:
	die()

func die() -> void:
	print("Player died")
	#TODO: add death logic
