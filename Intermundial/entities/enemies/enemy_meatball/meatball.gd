extends CharacterBody3D


## handles navigation and component control 

# animation conditions : 	idle 	chase 	 shoot 	  melee

var alive: bool = true
var can_shoot : bool = false
var chase : bool = false

@export var velocity_component : VelocityComponent
@export var nav_dummy : Node3D
@onready var animation_tree: AnimationTree = %AnimationTree


func _ready() -> void:
	pass


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
	position_nav_dummy()
	if velocity_component:
		if chase:
			chase_target()


## navigation

#shouldnt be called every frame very performance heavy
func chase_target():
	if not alive: return
	%NavigationAgent3D.target_position = get_tree().get_first_node_in_group("Player").global_position
	var direction: Vector3 = (%NavigationAgent3D.get_next_path_position() - global_position).normalized()
	#look_at(%NavigationAgent3D.get_next_path_position())
	%VelocityComponent.accelerate_in_direction(direction)





func kill_velocity():
	chase = false
	velocity_component.stop()

func decelerate():
	chase = false
	velocity_component.decelerate()

## Detection

func _on_detection_component_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !chase:
		chase = true
		print("alerted")

func _on_detection_component_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		decelerate()

func position_nav_dummy():
	if nav_dummy:
		if velocity_component.ground_raycast.is_colliding():
			if velocity_component.collision_point:
				nav_dummy. global_position = velocity_component.collision_point
		

## Melee
#
#func _on_melee_component_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#kill_velocity()
		#animation_tree["parameters/conditions/melee"] = true
		#print("melee")
#
#
#func _on_melee_component_body_exited(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#animation_tree["parameters/conditions/melee"] = false
		#chase = true
		#print("exit_melee")



func attempt_shoot():
	pass
