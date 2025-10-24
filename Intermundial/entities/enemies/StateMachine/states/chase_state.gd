@tool
extends State
class_name ChaseState

@export var chase_speed = 100

@onready var player = get_tree().get_first_node_in_group("Player")

func state_exited():
	self_root.velocity = Vector3.ZERO

func state_processing(_delta: float) -> void:
	self_root.nav_agent.set_target_position(player.global_position)
	self_root.look_at_player(player)

func state_physics_processing(delta: float) -> void:
	if self_root.nav_agent.is_navigation_finished():
		return
	
	var next_position: Vector3 = %NavigationAgent3D.get_next_path_position()
	self_root.velocity = self_root.global_position.direction_to(next_position) * chase_speed * delta
	
	#if self_root.global_position.distance_to(player.global_position) < self_root.melee_range:
		#print("trans/ chase - melee")
		#emit_signal("Transitioned",self,"MeleeState")
		
