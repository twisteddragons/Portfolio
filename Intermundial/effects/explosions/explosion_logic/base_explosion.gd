extends Node3D

var targets = []
@export var explosion_scene: PackedScene 
@export var horizontal_knockback: float = 15.0
@export var vertical_knockback: float = 8.0
@export var explosion_scale: Vector3 = Vector3(1, 1, 1)
@export var explosion_damage: float = 10.0

func _on_area_3d_body_entered(body: Node3D) -> void:
	targets.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	targets.erase(body)


func _on_delay_timeout() -> void:
	print("timeout")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.scale = explosion_scale
		if explosion.has_method("explode"):
			explosion.explode()
	
	# Apply forces and damage
	apply_knockback_to_targets()
	queue_free()

func apply_knockback_to_targets():
	for target in targets:
		if not is_instance_valid(target):
			continue
		
		# Calculate knockback direction
		var direction = (target.global_position - global_position).normalized()
		var horizontal_force = Vector3(direction.x, 0, direction.z).normalized() * horizontal_knockback
		var vertical_force = Vector3.UP * vertical_knockback
		
		var total_force = horizontal_force + vertical_force
		# Apply to different body types
		if target is CharacterBody3D:
			apply_character_knockback(target, horizontal_force + vertical_force)
		elif target is RigidBody3D:
			target.apply_impulse(total_force)
		
		# Apply damage
		if target.has_method("take_damage"):
			target.take_damage(explosion_damage)

func apply_character_knockback(character: CharacterBody3D, force: Vector3):
	if character.has_method("apply_knockback"):
		character.apply_knockback(force)
