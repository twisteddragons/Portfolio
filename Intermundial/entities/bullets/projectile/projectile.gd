extends Node3D

signal gun_dealt_damage
signal gun_dealt_effect
signal bullet_landed(position: Vector3)

const LIFETIME:float = 4.0

@onready var timer = $Timer
@onready var ray = $RayCast3D

var ignore_group:String
var bullet_info:Bullet
var gravity_scale:float = 0.0
var speed:float
var carrot_mode:bool = true

func _ready() -> void:
	assert(ignore_group, "Projectile missing ignore group. Please configure.")
	assert(bullet_info, "Projectile missing bullet info. Please configure.")
	gravity_scale = bullet_info.get_gravity_scale()
	speed = bullet_info.get_projectile_speed()
	timer.timeout.connect(self.queue_free)
	timer.start(LIFETIME)
	if carrot_mode:
		$carrot_mode.show()

func _process(delta) -> void:
	position += transform.basis * Vector3(0,-speed, 0) * delta
	if gravity_scale:
		## NOTE: If the camera basis is below the horizon, z is 0, otherwise 180
		if rotation.z > 0: rotation += Vector3(gravity_scale, 0,0)*delta
		else: rotation -= Vector3(gravity_scale, 0,0)*delta
	if ray.is_colliding():
		# Get data
		var target = ray.get_collider()
		if target.is_in_group(ignore_group): return
		var hit_pos = ray.get_collision_point()
		Collections.stat_tracker.player_last_hitscan_positions = [hit_pos]
		emit_signal("bullet_landed", hit_pos)
		# Trigger damage and effects
		bullet_info.get_bullet_regular_effect()
		if target.is_in_group(Collections.GLOBAL_GROUPS.DAMAGEABLE):
			target.take_damage(bullet_info.get_damage())
			emit_signal("gun_dealt_damage")
		if target.is_in_group(Collections.GLOBAL_GROUPS.EFFECTABLE):
			bullet_info.get_bullet_effect(target)
			emit_signal("gun_dealt_effect")
		queue_free()
