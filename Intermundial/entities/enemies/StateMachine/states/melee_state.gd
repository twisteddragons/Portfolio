@tool
extends State
class_name MeleeState

#var initial_attack_delay = 0.1
#
#func enter():
	## short delay before attack to make avoidance possible
	#self_root.velocity.x = 0
	#self_root.velocity.z = 0
	#self_root.look_at_player(player)
	#await get_tree().create_timer(initial_attack_delay).timeout
	#melee_attack()
#
#func state_process(_delta: float) -> void:
	#pass
#
#
#func melee_attack():
	## deals damage if player is in hurtbox
	#self_root.look_at_player(player)
	##play short attack animation here
	#player.take_damage(self_root.melee_damage)
	#
	## delay after attack to let player get away
	#var melee_cooldown_timer = self_root.melee_cooldown
	#await get_tree().create_timer(melee_cooldown_timer).timeout
	#check_attack_again()
#
#
## checks if player is still in range
#func check_attack_again():
	#if self_root.global_position.distance_to(player.global_position) > self_root.melee_range:
		#emit_signal("Transitioned",self,"ChaseState")
	#else:
		#melee_attack()
