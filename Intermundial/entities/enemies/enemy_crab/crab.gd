extends CharacterBody3D


var alive: bool = true
var can_shoot : bool = false
var chase : bool = false
var straf : bool = false
var player

@onready var animation_tree: AnimationTree = %AnimationTree

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


## damage/ death
func take_damage(damage):
	if not alive: return
	%HealthComponent.damage(damage)
	print("enemy took damage", damage)


func _on_health_component_died() -> void:
	if not alive: return
	alive = false
	# death anim goes here
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	if chase:
		chase_target()
	if straf:
		straf_target()


## navigation
func chase_target():
	if not alive: return
	%NavigationAgent3D.target_position = get_tree().get_first_node_in_group("Player").global_position
	var direction: Vector3 = (%NavigationAgent3D.get_next_path_position() - global_position).normalized()
	look_at(%NavigationAgent3D.get_next_path_position())
	%VelocityComponent.accelerate_in_direction(direction)

func straf_target():
	if not alive: return
	# honestly not 100% sure how this works what the fuck is .cross? works ok for now though
	var to_player = player.global_position - global_position
	var target_dir = to_player.cross(Vector3.UP).normalized()
	# would like to make strafe speed adjustible not really sure how to do that.
	var straf_dir = target_dir # speed change here?
	# switches strafe direction, could be randomized for more upredictable behaviour
	var time = Time.get_ticks_msec() / 1000.0
	if sin(time) > 0:
		straf_dir = -straf_dir
	
	%NavigationAgent3D.target_position = straf_dir
	var direction: Vector3 = (%NavigationAgent3D.get_next_path_position() - global_position).normalized()
	%VelocityComponent.accelerate_in_direction(direction)
	look_at(player.global_position)

func kill_velocity():
	chase = false
	%VelocityComponent.stop()

func decelerate():
	chase = false
	%VelocityComponent.decelerate()

## Detection

func _on_detection_component_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !chase:
		chase = false
		straf = true
		animation_tree["parameters/conditions/walking"] = true
		animation_tree["parameters/conditions/idle"] = false
		print("alerted")

func _on_detection_component_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		straf = false
		animation_tree["parameters/conditions/walking"] = false
		animation_tree["parameters/conditions/idle"] = true
		decelerate()
		
		

## Melee

#func _on_melee_component_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#kill_velocity()
		#animation_tree["parameters/conditions/melee"] = true
		#print("melee")


#func _on_melee_component_body_exited(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#animation_tree["parameters/conditions/melee"] = false
		#chase = true
		#print("exit_melee")



func attempt_shoot():
	pass
