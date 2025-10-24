extends CharacterBody3D

var alive: bool = true
var attacking : bool = false
var chase : bool = false
var straf : bool = false

var player

@export var velocity_component : VelocityComponent
@onready var animation_tree: AnimationTree = %AnimationTree


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


## damage/ death
func take_damage(damage):
	if not alive: return
	%HealthComponent.damage(damage)
	
	## enemy should chase player if they are being shot out of the enemy range
	if not straf:
		chase = true
	print("enemy took damage", damage)


func _on_health_component_died() -> void:
	if not alive: return
	alive = false
	# death anim goes here
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _physics_process(_delta: float) -> void:
	if velocity_component:
		if chase:
			chase_target()
		if straf:
			straf_target()


# using a more straight forward method of navigation as it allows for crossing gaps and going over objects 
func chase_target():
	if not alive: return
	
	# i think its ok to do this in process as it is alot less taxing then nav agents
	var direction : Vector3 = player.global_position - global_position
	%VelocityComponent.accelerate_in_direction(direction)
	
	#would be nice to make this smoother, maybe lerp rotation to player global position? , maxing the angle it can look down would be nice also
	look_at(player.global_position)

# attempting to make it so the enemy trys to dodge at a certain range, we could also make it back up when player is too close but idk if that would be fun
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
	
	%VelocityComponent.accelerate_in_direction(straf_dir)
	look_at(player.global_position)


func kill_velocity():
	chase = false
	straf = false
	velocity_component.stop()

func decelerate():
	chase = false
	straf = false
	velocity_component.decelerate()

## Detection

func _on_detection_component_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !chase:
		if !attacking:
			chase = true
			print("alerted")

func _on_detection_component_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		decelerate()

func _on_ranged_component_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if !attacking:
			chase = false
			straf = true

func _on_ranged_component_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if !attacking:
			chase = true
			straf = false


#attack one: bullet hell attack // i think this should only happen when player is within rangebox
func attempt_attack():
	decelerate()
	animation_tree["parameters/conditions/attack_1"] = true


#attack two: beam attack //  i think this should be able to happen at any time while the player is detected
func attempt_beam_attack():
	decelerate()
	animation_tree["parameters/conditions/attack_2"] = true

func end_attack():
	attacking = false
	pass
