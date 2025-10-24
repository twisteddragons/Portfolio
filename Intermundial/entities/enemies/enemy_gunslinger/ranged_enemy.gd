extends CharacterBody3D

## WIP

@export var health = 500
@export var RunSpeed : int = 10.0

# melee stuff
# can reuse for melee enemys by checking this 
@export var has_ranged_attack: bool = true
@export var melee_damage : float = 1.0
@export var melee_cooldown : float = 0.5
@export var melee_range : float = 2.0

#ranged stuff
@export var max_range : float = 20
@export var projectile : PackedScene
@export var ranged_cooldown : float = 0.5

@export var state_machine: StateMachine
@export var hitsound: AudioStreamPlayer3D 

#local player refrence:
var player: CharacterBody3D

var in_combat: bool = false
var can_see_target: bool = false

#nav agent
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
#detection
@onready var detection_range: Area3D = $vison/detection_range
@onready var vision_raycast: RayCast3D = $vison/vision_raycast
#melee hurt box
@onready var melee_hurtbox: Area3D = $attack_stuff/melee_hurtbox
#sounds
@onready var gunshot: AudioStreamPlayer3D = $Audio/gunshot




# had to do some weird stuff with getting states to load in the right order:
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

# base physics
func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	move_and_slide()


func _on_detection_range_body_entered(body: Node3D) -> void:
	if body == player and !in_combat :
		start_combat()




#line of sight stuff stolen form : https://www.youtube.com/watch?v=U0VBk2InzkA&t=2s
func _on_vison_timer_timeout() -> void:
	if self.global_position.distance_to(player.global_position) < max_range:
		var player_pos = player.global_position
		vision_raycast.look_at(player_pos, Vector3.UP)
		vision_raycast.force_raycast_update()
		
		# this is a fucking mess but it works
		if vision_raycast.is_colliding():
			var collider = vision_raycast.get_collider()
			
			if collider == player :
				can_see_target = true
				if ! in_combat:
					start_combat()
				
			else:
				can_see_target = false
	else:
		can_see_target = false

func attempt_shoot():
	var bullet_instance = projectile.instantiate()
	gunshot.play()
	bullet_instance.position = vision_raycast.global_position
	bullet_instance.transform.basis = vision_raycast.global_transform.basis
	get_tree().root.add_child(bullet_instance)

func start_combat():
	#combat check
	if in_combat:
		return
	in_combat = true
	
	
	alert_nearby_hostiles()

# forces any other enemys within range into combat
func alert_nearby_hostiles():
	var rally_collider = detection_range
	for body in rally_collider.get_overlapping_bodies():
		if body.is_in_group("enemy") and body != self and !body.in_combat:
			print("alerted")
			body.start_combat()


func look_at_player(player) -> void:
		var look_pos = player.global_position
		look_pos.y = global_position.y
		look_at(look_pos, Vector3.UP)

#func take_damage(amount: int) -> void:
	#health -= amount
	#is_alerted = true
	#hitsound.play()
	#start_combat()
	#print("enemy took damage", health)
	##blood_spawner.spawn_blood_at(global_position)
	#if health <= 0:
		#die()


func die():
	#queue_free()
	pass
