extends Node3D
## needs a cooldown, can kick self. should be merged to main script

signal player_kick
signal player_kicked_object

@onready var area: Area3D = $kick_col
@onready var kick_animation: AnimatedSprite2D = $"kick animation"
@onready var sound_manager: SoundEffectManager = %sound_manager



@export var knockback_force: float = 50.0
@export var kick_damage: float = 10.0

var targets = []

## TODO Move all this input into the player script
func _input(InputEvent) -> void:
	if Input.is_action_just_pressed("kick"):
		kick()

func kick():
	sound_manager.play_sound(07)
	kick_animation.play()
	emit_signal("player_kick")
	var kick_direction = -global_transform.basis.z.normalized()
	for body in area.get_overlapping_bodies():
		if body is RigidBody3D:
			sound_manager.play_sound(08)
			var knockback_vector = kick_direction * knockback_force
			body.apply_central_impulse(knockback_vector)
			emit_signal("player_kicked_object")
			# I wanna send the knockback_vector along with signal
			# Also, emit a signal when the player kicks the ground
		
		if body.has_method("take_damage"):
			body.take_damage(kick_damage)
