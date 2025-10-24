extends Node3D

const MIN_REPEAT_DELAY:float = 0.1

## Radius of effect. Curve spans this distance; when distance=radius, no effect.
@export var radius:float = 1.0
## Damage dealt at core. Falls off with curve.
@export var damage:float = 0.0
## Force applied to physics objects at core. Falls off with curve
@export var force:float = 10.0
## How often to repeat the blast. Set to 0.0 for no repeat.
@export var repeat_delay:float = 0.0
## How many times to repeat. Total number of explosions = this number + 1
@export var num_repeats:int = 0


@onready var repeat_timer:Timer = $Timer

func _ready() -> void:
	%Area3D.scale = Vector3(radius,radius,radius)
	repeat_timer.timeout.connect(self.explode)
	%ExplosionEffect.explosion_emission_finished.connect(queue_free)
	if num_repeats > 0: config_timer()
	else: explode()

func config_timer() -> void:
	if num_repeats > 0:
		assert(repeat_delay >= MIN_REPEAT_DELAY, "Explosion initialized with too short of delay: " + str(repeat_delay))
		repeat_timer.start(repeat_delay)

func explode() -> void:
	## NOTE: Requires two physics_frames. Might be able to prune one.
	await get_tree().physics_frame
	await get_tree().physics_frame
	%ExplosionEffect.explode()
	for c in %Area3D.get_overlapping_bodies():
		var factor: float = get_falloff(get_proximity(c))
		if c.is_in_group(Collections.GLOBAL_GROUPS.DAMAGEABLE):
			c.take_damage(damage*factor)
		var knockback:Vector3 = factor*force*(c.position - position).normalized()
		if c.has_method("apply_central_impulse"):
			c.apply_central_impulse(knockback)
		elif "velocity" in c:
			c.velocity += knockback
	if num_repeats > 0:
		num_repeats -= 1
		config_timer()

## Returns a value based on its proximity to effect. On top of effect returns 1,
## at radius, returns 0.
func get_proximity(body:Node3D) -> float:
	var distance:float = (body.global_position - global_position).length()
	return abs((radius-distance)/radius)

## Runs proximity through falloff curve. If none supplied, defaults to x^(1/3).
func get_falloff(proximity:float) -> float:
	return pow(proximity, 0.333)
