class_name Player
extends CharacterBody2D

#@onready var wings: CharacterBody2D = $Wings
@onready var cockpit: Area2D = $Cockpit

@export var input_disabled = false ## whether or not the player can control the character
@export var clockwise = true ## whether the plane starts going clockwise or counter clockwise
@export_group("Movement Values")
@export var base_speed_amt: float = 150 ## default movement speed
@export var base_rot_speed_amt: float = 1 ## default rotation speed
@export var speed_boost_amt: float = 250 ## default speed boost increase for a single boost
@export var rot_speed_boost_amt: float = 0.5 ## default rotation boost
@export var knockback_speed_amt: float = 1000 ## default movement knockback speed
@export var rot_knockback_amt: float = 4.5 ## rotation knockback speed
@export var knockback_duration: float = 0.3 ## knockback duration in seconds
@export var iframes_duration: float = 0.3 ## iframes duration in seconds
@export_group("Shape and Sprites")
@export var current_plane_type: Enums.PlaneTypes = Enums.PlaneTypes.L: ## Current shape of plane
	get: 
		return current_plane_type
	set(value):
		set_plane_type(load("res://Entities/Player/Hitboxes/" + Enums.PlaneTypes.find_key(value) + ".tres"),\
			load("res://Entities/Player/Art/Wings/" + current_wing_skin_library + "/" + Enums.PlaneTypes.find_key(value) + ".png"))
		current_plane_type = value
		update_forcefield()

@export var current_wing_skin_library: String = "Base": ## Current skin set of plane's wings
	get:
		return current_wing_skin_library
	set(value):
		set_wings(load("res://Entities/Player/Art/Wings/" + value + "/" + Enums.PlaneTypes.find_key(current_plane_type) + ".png"))
		current_wing_skin_library = value.to_pascal_case()
@export var current_cockpit_skin: String = "base": ## Current skin of plane's cockpit
	get:
		return current_cockpit_skin
	set(value):
		%CockpitSprite.texture = load("res://Entities/Player/Art/Cockpits/" + value + ".png")
		current_cockpit_skin = value.to_lower()

signal health_changed(new_value: int)
signal took_damage()
signal player_died()

var lives: int = 3: ## Health of the player
	get:
		return lives
	set(value):
		health_changed.emit(value)
		lives = value
var knockback_normal: Vector2 = Vector2(0,0) ## which direction play will get knockbacked to
var knockback_speed: float = 0 ## How much knockback is currently being applied
var rot_knockback_speed: float = 0 ## How much rotation knockback is currently being applied
var rot_dir: int = 1 ## rotation Direction 1 is clockwise, -1 is counter clockwise, changes when it hits a spring
var iframes: bool = false
var invincible: bool = false:
	get:
		return invincible
	set(value):
		%ForceField.visible = value
		invincible = value
var rot_knockback_tween: Tween ## refernce to current rotation knockback tween
var knockback_tween: Tween ## refernce to current knockback tween
var frozen: bool = false
var alive: bool = true ## false when player dies, no actions are allowed when dead

func _ready():
	%ForceField.visible = true
	update_forcefield()
	if !clockwise:
		rot_dir = -1

func _process(delta):
	if !alive:
		return
	
	# movement handling
	var boost_speed: float = 0
	var input_direction: Vector2 = Vector2(0,0)
	if !input_disabled:
		input_direction = Input.get_vector("left", "right", "up", "down")
		if Input.is_action_pressed("accel_1"):
			boost_speed += speed_boost_amt
		if Input.is_action_pressed("accel_2"):
			boost_speed += speed_boost_amt
	
	# apply movement
	velocity = (input_direction * (base_speed_amt + boost_speed)) + (knockback_normal * knockback_speed)
	if velocity != Vector2.ZERO:
		pass #TODO: play driving sfx here
	
	# rotation handling
	var rot_boost: float = 0
	if Input.is_action_pressed("rotation_accel") and !input_disabled:
		rot_boost += rot_speed_boost_amt
	
	# apply rotation
	var total_rot: float = 0
	if !frozen:
		total_rot += base_rot_speed_amt 
	total_rot += rot_boost + rot_knockback_speed
	total_rot *= rot_dir # rotate correct direction
	rotation += total_rot * delta
	
	# make sure cockpit is always right side up
	$Cockpit.global_rotation = 0
	
	move_and_slide() # TODO: use move_and_collide instead
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		collide(collision)
	
	# update frozen visual timer
	%SnowflakeProgressBar.value = (%FrozenTimer.time_left / %FrozenTimer.wait_time) * 100

func collide(collision: KinematicCollision2D):
	if !alive:
		return
	
	## Knockback calculation
	var u: Vector2 = collision.get_normal() ## Vector pointing away from object collided with
	apply_knockback(u, knockback_speed_amt, knockback_duration)
	
	## Rotation knockback calculation
	u = u.orthogonal() ## rotate 90 degrees counter clockwise
	var v: Vector2 = global_position.direction_to(collision.get_position()) ## Vector pointing from ship center to collision point
	var dot: float = v.dot(u) ## Positive if on one "side" of plane, negative if on the other
	var reverse_dir: bool = false ## whether or not the rotation should reverse temporarily.
	if dot * rot_dir <= 0: ## essentially an if statement simplified. e.g. if rot_dir is clockwise (1) and dot is negative, reverse direction
		reverse_dir = true
	apply_rotation_knockback(rot_knockback_amt, knockback_duration, reverse_dir)
	
	## Take damage
	if !iframes and !invincible:
		lives -= 1
		took_damage.emit()
		$DamageAudio.play()
		if lives <= 0:
			die() 
			pass
		handle_temp_invincibility()
		var particle_emitter = %HitParticles.duplicate()
		add_child(particle_emitter)
		particle_emitter.connect("finished", particle_emitter.queue_free)
		particle_emitter.global_position = collision.get_position()
		particle_emitter.emitting = true
	elif invincible:
		$ShieldAudio.play()
	
	## handle collision sound
	#if invincible:
		#$InvincibilitySound.play()
	#else:
		#$DamageSound.play()

## PARAM: direction: direction to travel in knockback
func apply_knockback(direction: Vector2, strength: float, duration: float):
	if !alive:
		return
	knockback_normal = direction.normalized()
	knockback_speed = strength #knockback_speed_amt
	if knockback_tween: #if already in knockback, restart tween
		knockback_tween.kill()
	knockback_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	knockback_tween.tween_property(self, "knockback_speed", 0, duration)

## PARAM: reverseDir: true when direction should change temporarily
func apply_rotation_knockback(strength: float, duration: float, reverse_dir: bool):
	if !alive:
		return
	rot_knockback_speed = strength
	if reverse_dir:
		rot_knockback_speed *= -1
	if rot_knockback_tween: ## if already in knockback, restart tween
		rot_knockback_tween.kill()
	rot_knockback_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	rot_knockback_tween.tween_property(self, "rot_knockback_speed", 0, duration)

## creates a vector orthogonal to the springs up vector
#func hit_spring(springRot: float, springPos: Vector2):
	#if !alive:
		#return
	#
	#var u: Vector2 = Vector2.UP
	#u = u.rotated(springRot)
	#var foo: Vector2 = u.orthogonal() #goes 90 deg counter clockwise now points left relative to spring
	#var v: Vector2 = global_position.direction_to(springPos) #vector pointing to spring
	#var dot: float = foo.dot(v) # neg if obtuse, pos if acute, 0 if right (0 is irrelevant)
	#var reverse_dir: bool = false
	#if dot * rot_dir <= 0: # if spring is on correct side for current rotation direction, rotate other way
		#rot_dir = -rot_dir
		#reverse_dir = true
	#apply_rotation_knockback(knockback_speed_amt, knockback_duration, reverse_dir)
	#apply_knockback(u, knockback_speed_amt, knockback_duration) ## TODO: have different knockback speed for spring

func reverse_spin_direction():
	rot_dir = -rot_dir

func freeze(freeze_duration: float):
	frozen = true
	if %FrozenTimer.is_stopped():
		%FrozenTimer.start(freeze_duration)
	else:
		%FrozenTimer.start(%FrozenTimer.time_left + freeze_duration)

func handle_temp_invincibility():
	if !alive:
		return
	iframes = true
	await get_tree().create_timer(iframes_duration, false).timeout
	iframes = false

func heal(): 
	if !alive:
		return
	lives = 3

## Kill player, called when health is 0 or below
func die():
	if !alive:
		return
	alive = false
	player_died.emit()
	visible = false

## Change the characters palette to the provided palette
func set_palette(new_palette: ShaderMaterial):
	%WingsSprite.material = new_palette
	%CockpitSprite.material = new_palette

## Change the characters cockpit texture to provided texture
func set_cockpit(new_cockpit: Texture):
	%CockpitSprite.texture = new_cockpit

## Swap hitbox and wings texture to new type
func set_plane_type(new_hitbox: ConvexPolygonShape2D, new_sprite: Texture):
	%WingsHitbox.polygon = new_hitbox.points
	set_wings(new_sprite)

## Change the characters wings texture to provided texture
func set_wings(new_wings: Texture):
	%WingsSprite.texture = new_wings

## changed the forcefields shape to the current wing shape
## NOTE: if the wings are multiple polygons, only uses one pretty much at random
func update_forcefield():
	var sprite_path: String = %WingsSprite.texture.resource_path ## get path of current wings
	var wing_polygons: Array[PackedVector2Array] = HelperFuncs.image_to_polygons(sprite_path, 4) ## convert sprite to polygons
	var cockpit_polygons: Array[PackedVector2Array] = HelperFuncs.image_to_polygons("res://entities/player/art/cockpits/base.png", 4)
	var merged_polygons: Array[PackedVector2Array] = Geometry2D.merge_polygons(wing_polygons[0], cockpit_polygons[0])
	var temp_line2d = Line2D.new() ## convert points to line
	temp_line2d.points = merged_polygons[0] ## take first polygons points
	temp_line2d = HelperFuncs.tessalate_line_even_length(temp_line2d, 5, 6) ## tessalate
	%ForceField.call_deferred("set_wiggly_points", temp_line2d.points) ## set points between frames

func _on_safe_zone_enter_checkpoint(plane_type: Enums.PlaneTypes, safe_zone: SafeZone):
	invincible = true
	heal()
	
	#return ##TODO: remove later, need assets now
	## change plane type TODO: move this to safe zone? or even level controller?????????
	if plane_type != Enums.PlaneTypes.NONE and plane_type != current_plane_type:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", safe_zone.global_position, 0.5)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_QUAD)
		await tween.finished
		current_plane_type = plane_type
		#var wings_hitbox_path = "res://Entities/Player/Hitboxes/" + str(Enums.PlaneTypes.keys()[plane_type]) + ".tres"
		#var wings_sprite_path = "res://Entities/Player/Art/Wings/" + current_wing_skin_library + "/" + str(Enums.PlaneTypes.keys()[plane_type]) + ".png"
		#set_plane_type(load(wings_hitbox_path), load(wings_sprite_path))

func _on_safe_zone_leave_checkpoint():
	invincible = false


func _on_frozen_timer_timeout():
	frozen = false
