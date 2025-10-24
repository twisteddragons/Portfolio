extends CharacterBody3D

## handles navigation and component control //
## most enemys should be able to use this

# animation conditions : 	idle 	chase 	 shoot 	  melee

var alive: bool = true
var can_shoot : bool = true
var alert : bool = false
#var chase : bool = false

var player
var bullet:Bullet

const MAX_SHOTS_PER_GUN:int = 2
var remaining_shot_count:int = MAX_SHOTS_PER_GUN * 2

@onready var animation_tree: AnimationTree = %AnimationTree

func _ready() -> void:
	#get player ref
	player = get_tree().get_first_node_in_group("Player")
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
	if can_shoot:
		var flattended_direction = player.global_position
		flattended_direction.y = global_position.y
		look_at(flattended_direction)

## Detection

func _on_detection_component_body_entered(body: Node3D) -> void:
	if not alive: return
	if body.is_in_group("Player") and !alert:
		alert = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/alert"] = true
		

func _on_detection_component_body_exited(body: Node3D) -> void:
	if not alive: return
	if body.is_in_group("Player"):
		alert = false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/alert"] = false
		

## Melee // uneeded for now

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

func _on_ranged_component_body_entered(body: Node3D) -> void:
	if not alive: return
	if body is Player:
		attempt_shoot()

func _on_ranged_component_body_exited(body: Node3D) -> void:
	if not alive: return
	if body is Player:
		animation_tree["parameters/conditions/shoot"] = false

func attempt_shoot():
	if not alive: return
	# TODO Before firing, check if player is in range
	animation_tree["parameters/conditions/shoot"] = true

func fire_projectile():
	if not alive: return
	var p = Collections.projectile_scene.instantiate()
	p.position = %ShootRaycast.global_position
	p.transform.basis = %ShootRaycast.global_transform.basis
	p.ignore_group = Collections.GLOBAL_GROUPS.ENEMY
	p.bullet_info = bullet.duplicate()
	Util.get_projectile_entity_node().add_child(p)
	remaining_shot_count -= 1
	if remaining_shot_count <= 0:
		animation_tree["parameters/conditions/reload"] = true

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if not alive: return
	if "shoot" in anim_name:
		fire_projectile()
	if anim_name == "reload":
		animation_tree["parameters/conditions/reload"] = false
		remaining_shot_count = MAX_SHOTS_PER_GUN * 2
