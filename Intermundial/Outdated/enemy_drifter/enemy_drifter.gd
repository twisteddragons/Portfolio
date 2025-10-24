extends CharacterBody3D

@onready var animation_tree: AnimationTree = %AnimationTree

var alive:bool = true

func _physics_process(delta):
	if not alive: return
	#look_at(get_tree().get_first_node_in_group("Player").global_position)
	pass
	
func take_damage(damage):
	if not alive: return
	$HealthComponent.damage(damage)

## CHASE STATE

func _on_chase_state_physics_processing(delta):
	if not alive: return
	%NavigationAgent3D.target_position = get_tree().get_first_node_in_group("Player").global_position
	var direction: Vector3 = (%NavigationAgent3D.get_next_path_position() - global_position).normalized()
	look_at(%NavigationAgent3D.get_next_path_position())
	$VelocityComponent.accelerate_in_direction(direction)
	for body in %MeleeHitbox.get_overlapping_bodies():
		if body is Player:
			%StateChart.send_event("player_entered_attack_hitbox")

func _on_chase_state_exited():
	if not alive: return
	$VelocityComponent.decelerate()


## MELEE STATE

func _on_melee_state_entered():
	if not alive: return
	animation_tree["parameters/conditions/melee"] = true

func _on_melee_state_processing(_delta):
	if not alive: return
	#$StateChartAnimationPlayer.play("attack")


## NORMAL SIGNALS

func _on_detection_range_body_entered(body) -> void:
	if not alive: return
	if body is Player:
		%StateChart.send_event("player_entered_range")
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/chase"] = true


func _on_detection_range_body_exited(body):
	if not alive: return
	if body is Player:
		%StateChart.send_event("player_exited_range")
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/chase"] = false


func _on_melee_hitbox_body_entered(body):
	if not alive: return
	if body is Player:
		%StateChart.send_event("player_entered_attack_hitbox")


func _on_health_component_died() -> void:
	if not alive: return
	alive = false
	%StateChart.send_event("character_died")
	queue_free()
