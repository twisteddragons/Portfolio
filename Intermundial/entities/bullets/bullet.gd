class_name Bullet
extends Sprite2D

@export var bullet_resource:SpecialBullet = preload("uid://dqdk2b68n63w8")

var custom_fire_audio:AudioStream = null

func _init() -> void:
	change_type(bullet_resource)

## NOTE: Need to call at init and ready in case bullet_resource changes (which it might)
func _ready() -> void:
	change_type(bullet_resource)

# TODO: Alternate call with uid_path:String to be load(...)-ed?
func change_type(new_type:SpecialBullet) -> void:
	bullet_resource = new_type
	set_texture(bullet_resource.back_sprite)
	if bullet_resource.fire_sound_uid: custom_fire_audio = load(bullet_resource.fire_sound_uid)
	else: custom_fire_audio = null
	
func get_bullet_type() -> Collections.BULLET_TYPES:
	return bullet_resource.bullet_type

## To be called by affected node to trigger the effect.
## Pass the caller when able for full functionality
func get_bullet_effect(caller:Node3D=null) -> void:
	bullet_resource.get_effect(caller, self)

## To be called by the weapon manager every time a bullet lands (hitscan or
## projectile lands).
func get_bullet_regular_effect(caller:Node3D=null) -> void:
	bullet_resource.get_regular_effect(caller, self)

## To be called every time the bullet is fired.
func get_on_fire_effect() -> void:
	bullet_resource.get_on_fire_effect(self)

## To be called by the weapon manager to determine how the bullet should fire
func get_fire_type() -> Collections.FIRE_TYPES:
	return bullet_resource.fire_type

## To be called by projectiles during _ready
func get_gravity_scale() -> float:
	return bullet_resource.projectile_gravity_scale

## To be called by projectiles during _ready
func get_projectile_speed() -> float:
	return bullet_resource.projectile_speed

func get_damage() -> int:
	return bullet_resource.damage

## Returns the custom audio stream of the fire sound if available
func get_custom_audio() -> AudioStream:
	return custom_fire_audio
