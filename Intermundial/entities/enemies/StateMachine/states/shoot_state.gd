@tool
extends State
class_name ShootState

@export var initial_attack_delay: float = 0.2
@export var clip_size: int = 1
@export var shot_speed: float = 0.1
@export var reload: float = 3.0

#var initial_attack_delay = 0.2
#
#func enter():
	## short delay before attack to make avoidance possible
	#print("entered shoot")
	#self_root.velocity.x = 0
	#self_root.velocity.z = 0
	#self_root.look_at_player(player)
	#await get_tree().create_timer(initial_attack_delay).timeout
	#shoot()
#
#
#func shoot():
	#print("shoot")
	#self_root.look_at_player(player)
	##play short attack animation here
	#self_root.attempt_shoot()
	#
	## range cooldown
	#var ranged_cooldown_timer = self_root.ranged_cooldown
	#await get_tree().create_timer(ranged_cooldown_timer).timeout
	#check_attack_again()
#
#
## checks if player is still in range
#func check_attack_again():
	#if !self_root.can_see_target:
		##emit_signal("Transitioned",self,"IdleState")
		#await get_tree().create_timer(0.2).timeout
		#check_attack_again()
		#pass
	#else:
		#shoot()
