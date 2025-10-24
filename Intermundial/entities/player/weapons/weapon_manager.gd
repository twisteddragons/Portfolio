extends Node
class_name WeaponManager

# Signals
signal gun_reloaded
signal gun_fired
signal gun_dry_fired
signal gun_shot
signal gun_dealt_damage
signal gun_dealt_effect
signal bullet_landed(position: Vector3)

const CLUSTER_RAYCAST_VARIANCE: float = deg_to_rad(5.0)
const RAYCAST_DEFAULT_ROTATION: Vector3 = Vector3(deg_to_rad(90.0), 0.0, 0.0)

# References
@export var player : CharacterBody3D
@export var animation_sprite : AnimatedSprite2D
@export var bullet_raycast : RayCast3D
@export var cluster_raycasts: Node3D
@export var projectile_raycast: RayCast3D
#@export var muzzle_flash : GPUParticles3D

# Cylinder References
@export var cylinder_node: Node2D  # The parent node of the cylinder

# State
var is_reloading : bool = false
var is_rotating_cylinder: bool = false
var trigger_pressed : bool = false
var active_chamber_index: int = 0
var number_of_chambers: int = 6

@onready var active_chamber: Node2D = %Cylinder.get_child(0)
@onready var bullet_scene:PackedScene = preload("uid://cgicsjrgenlbl")
@onready var projectile_scene:PackedScene = preload("uid://di1oimjhqtjx")
@onready var cylinder = %Cylinder
@onready var default_shot_sound:AudioStream = preload("uid://c78gbyp8tlysb")
@onready var sound_manager: SoundEffectManager = %sound_manager

#@onready var gunflash: AnimatedSprite2D = %Gunflash



func _ready() -> void:
	# Initialize cylinder with starting pattern
	var start_pattern = Collections.stat_tracker.starting_cylinder_pattern.duplicate(true)
	for i in start_pattern:
		Collections.add_bullet(i, true)
	# Add a few basic bullets
	#for i in range(3):
	#	Collections.add_bullet(Collections.BULLET_TYPES.BASIC)
	refresh_cylinder()

func rotate_cylinder(degrees: float) -> bool:
	if is_reloading or is_rotating_cylinder: return false
	is_rotating_cylinder = true  # To be disabled by signal
	# Create smooth rotation tween
	var tween = create_tween()
	tween.finished.connect(_handle_rotation_tween_finished)
	var target_rotation = cylinder_node.rotation_degrees + degrees
	tween.tween_property(cylinder_node, "rotation_degrees", target_rotation, 0.15)
	# Play click sound
	sound_manager.play_sound(04)
	
	return true

func try_fire() -> bool:
	if is_reloading: return false
	
	# Dry fire if chamber is empty
	if active_chamber.get_child_count() == 0:
		sound_manager.play_sound(05)
		print("attempt sound")
		emit_signal("gun_dry_fired")
		return false
	
	# Play shoot animation
	if animation_sprite.animation == "shoot":
		animation_sprite.stop()
	animation_sprite.play("shoot")
	
	#gunflash.play()
	
	emit_signal("gun_shot")

	# Get bullet information
	var bullet_info:Bullet = active_chamber.get_child(0)
	
	# Play shot sound; switch to custom fire sound if any
	var shot_sound = bullet_info.get_custom_audio()
	if !shot_sound :
		shot_sound = default_shot_sound
	sound_manager.play_gunshot(shot_sound)
	
	emit_signal("gun_shot")
	var hit: bool
	match bullet_info.get_fire_type():
		Collections.FIRE_TYPES.SINGLE_HITSCAN:
			hit = fire_type_single_hitscan(bullet_info)
		Collections.FIRE_TYPES.CLUSTER_HITSCAN:
			hit = fire_type_cluster_hitscan(bullet_info)
		Collections.FIRE_TYPES.PROJECTILE:
			hit = fire_type_projectile(bullet_info)
	
	# Expend the bullet
	active_chamber.get_child(0).queue_free()
	return true
	
func fire_type_single_hitscan(bullet_info:Bullet) -> bool:
	return do_hitscan(bullet_raycast, bullet_info)

func fire_type_cluster_hitscan(bullet_info:Bullet) -> bool:
	var hit_anything:bool = false
	# TODO Add max_raycasts property to bullet resource <= player's cluster raycasts
	for raycast:RayCast3D in cluster_raycasts.get_children():
		# Randomize raycast direction
		raycast.rotation = RAYCAST_DEFAULT_ROTATION
		raycast.rotation.x += randf_range(-CLUSTER_RAYCAST_VARIANCE, CLUSTER_RAYCAST_VARIANCE)
		raycast.rotation.y += randf_range(-CLUSTER_RAYCAST_VARIANCE, CLUSTER_RAYCAST_VARIANCE)
		hit_anything = do_hitscan(raycast, bullet_info) or hit_anything
	return hit_anything

func do_hitscan(raycast:RayCast3D, bullet_info:Bullet) -> bool:
	bullet_info.get_on_fire_effect()
	if raycast.is_colliding():
		var damage_to_apply = bullet_info.get_damage()
		var target = raycast.get_collider()
		var hit_pos = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		# Update stat tracker
		Collections.stat_tracker.player_last_hitscan_positions = [hit_pos]
		# Spawn bullet decal
		BulletDecalPool.spawn_bullet_decal(hit_pos, normal, target)
		emit_signal("bullet_landed", hit_pos)
		# If bullet has a regular effect, trigger it
		bullet_info.get_bullet_regular_effect(target)
		# Apply physics impulse
		if target is RigidBody3D:
			target.apply_impulse(-normal * 5.0 / target.mass, hit_pos - target.global_position)
		# Apply damage and special effects
		if target.is_in_group(Collections.GLOBAL_GROUPS.DAMAGEABLE):
			target.take_damage(damage_to_apply)
			emit_signal("gun_dealt_damage")
		if target.is_in_group(Collections.GLOBAL_GROUPS.EFFECTABLE):
			bullet_info.get_bullet_effect(target)
			emit_signal("gun_dealt_effect")
		return true
	return false

func fire_type_projectile(bullet_info:Bullet) -> bool:
	var p = projectile_scene.instantiate()
	p.position = projectile_raycast.global_position
	p.transform.basis = projectile_raycast.global_transform.basis
	p.ignore_group = Collections.GLOBAL_GROUPS.PLAYER
	p.bullet_info = bullet_info.duplicate()
	Util.get_projectile_entity_node().add_child(p)
	return false

## Attempt to reload
func try_reload(_custom_bullet:SpecialBullet=null) -> void:
	# Cancel reload if any bullets remain
	for i in range(6):
		if cylinder.find_child("chamber"+str(i)).get_child_count() > 0:
			return
	# Play animation (on end of start, do_reload is called - see _on_animation_finished()
	play_animation("reload_start")
	sound_manager.play_sound(06)

func do_reload() -> void:
	# Empty cylinder tracker and pull bullets from the pouch
	Collections.cylinder_contents = []
	for i in range(6):
		Collections.load_random_bullet()
	refresh_cylinder()
	emit_signal("gun_reloaded")

## Goes through cylinder tracker and puts bullet objects into chambers
func refresh_cylinder() -> void:
	for i in range(6):
		# Clear chamber
		if cylinder.find_child("chamber"+str(i)).get_child_count() > 0:
			cylinder.find_child("chamber"+str(i)).get_child(0).queue_free()
		var b = Collections.cylinder_contents[i]
		cylinder.find_child("chamber"+str(i)).add_child(b)

func next_chamber() -> void:
	if not rotate_cylinder(60): return
	active_chamber_index = (active_chamber_index+1)%number_of_chambers
	active_chamber = %Cylinder.find_child("chamber"+str(active_chamber_index))

func previous_chamber() -> void:
	if not rotate_cylinder(-60): return
	active_chamber_index = (active_chamber_index+number_of_chambers-1)%number_of_chambers
	active_chamber = %Cylinder.find_child("chamber"+str(active_chamber_index))

func play_animation(anim_name: String) -> void:
	if animation_sprite.sprite_frames.has_animation(anim_name):
		animation_sprite.play(anim_name)

func _on_animation_finished() -> void:
	match animation_sprite.animation:
		"shoot":
			play_animation("idle")
		"reload_start":
			do_reload()
			play_animation("reload_end")
		"reload_end":
			is_reloading = false
			play_animation("idle")

## Connected to rotation tween in rotate_cylinder
func _handle_rotation_tween_finished() -> void:
	is_rotating_cylinder = false

## Debug functions (for test functionality)
func debug_1() -> void:
	try_reload(load("res://entities/bullets/dev_bullet/dev_bullet.tres"))
func debug_2() -> void:
	try_reload(load("res://entities/bullets/gas_bullet/gas_bullet.tres"))
func debug_3() -> void:
	try_reload(load("res://entities/bullets/shotgun_shell/shotgun_shell.tres"))
