extends Node3D

## handles navigation and component control //
## most enemys should be able to use this

# animation conditions : 	idle 	chase 	 shoot 	  melee

@export var reload_delay_min:float = 2.0
@export var reload_delay_max:float = 5.0
@export var melee_damage:float = 30.0

var alive: bool = true
var can_shoot : bool = false
var chase : bool = false
var bullet: Bullet

@onready var animation_tree: AnimationTree = %AnimationTree

func _ready() -> void:
	bullet = Collections.bullet_scene.instantiate()
	bullet.bullet_resource = load("uid://sqqtso78gsyp")

## damage/ death
func take_damage(damage):
	if not alive: return
	%HealthComponent.damage(damage)


func _on_health_component_died() -> void:
	if not alive: return
	alive = false
	# death anim goes here
	#await get_tree().create_timer(1.0).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	if not alive: return
	if chase:
		chase_target()
		if animation_tree["parameters/conditions/chase"] == false:   # animation toggle
			animation_tree["parameters/conditions/chase"] = true
	else:
		chase_target(true)


## navigation
func chase_target(pivot_only:bool=false):
	if not alive: return
	%NavigationAgent3D.target_position = get_tree().get_first_node_in_group("Player").global_position
	var direction: Vector3 = (%NavigationAgent3D.get_next_path_position() - global_position).normalized()
	var flattened_direction: Vector3 = %NavigationAgent3D.get_next_path_position()
	flattened_direction.y = global_position.y
	look_at(flattened_direction)
	if not pivot_only:
		%VelocityComponent.accelerate_in_direction(direction)

func kill_velocity():
	if not alive: return
	chase = false
	%VelocityComponent.stop()

func decelerate():
	if not alive: return
	chase = false
	%VelocityComponent.decelerate()

## Detection

func _on_detection_component_body_entered(body: Node3D) -> void:
	if not alive: return
	if body.is_in_group("Player") and !chase:
		chase = true

func _on_detection_component_body_exited(body: Node3D) -> void:
	if not alive: return
	if body.is_in_group("Player"):
		decelerate()
		animation_tree["parameters/conditions/chase"] = false
		animation_tree["parameters/conditions/idle"] = true
		

## Melee

func _on_melee_component_body_entered(body: Node3D) -> void:
	if not alive: return
	if body.is_in_group("Player"):
		kill_velocity()
		animation_tree["parameters/conditions/melee"] = true


func _on_melee_component_body_exited(body: Node3D) -> void:
	if not alive: return
	if body.is_in_group("Player"):
		animation_tree["parameters/conditions/melee"] = false
		chase = true

func do_melee() -> void:
	if not alive: return
	for body in %MeleeComponent.get_overlapping_bodies():
		if body is Player:
			shot_cooldown()
			body.take_damage(melee_damage)

## Shoot

func _on_ranged_component_body_entered(body: Node3D) -> void:
	if not alive: return
	if body is Player:
		shot_cooldown()

func _on_shoot_cooldown_timeout() -> void:
	if not alive: return
	chase = false
	attempt_shoot()

func attempt_shoot():
	if not alive: return
	# TODO Before firing, check if player is in range
	animation_tree["parameters/conditions/can_shoot"] = true
	%ShootRaycast.set_target_position(Collections.get_player().position - position)

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if not alive: return
	if anim_name == "shoot_stance":
		fire_projectile()

func fire_projectile():
	if not alive: return
	var p = Collections.projectile_scene.instantiate()
	p.position = %ShootRaycast.global_position
	p.transform.basis = %ShootRaycast.global_transform.basis
	p.ignore_group = Collections.GLOBAL_GROUPS.ENEMY
	p.bullet_info = bullet.duplicate()
	Util.get_projectile_entity_node().add_child(p)
	animation_tree["parameters/conditions/can_shoot"] = false
	chase = true
	shot_cooldown()

func shot_cooldown():
	if not alive: return
	%ShootTimer.wait_time = randf_range(reload_delay_min , reload_delay_max)
	%ShootTimer.start()
