extends Node3D

const GRAPPLE_FORCE: float = 80.0
const PLAYER_OBJECT_WEIGHT_RATIO: float = 0.25
const MAX_VERTICAL_SPEED: float = 10.0

var shooter:PhysicsBody3D
var target  # Either PhysicsBody3D or Vector3
var kill_process:bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# If target was destroyed by bullet, cancel grapple
	if not target: return
	# If end trigger, skip process
	if kill_process: return
	# Follow the player for one end of the rope
	position = shooter.position
	if target is Vector3:
		# Apply force to player
		shooter.velocity = ((target - shooter.position).normalized() * GRAPPLE_FORCE)
		# Stretch rope between player and target
		look_at(target)
		scale.z = (target - shooter.position).length()
	elif target is RigidBody3D:
		## TODO: if object is grabbed, call _on_player_released_fire() immediately (prevents flying)
		# Apply force to player and target
		shooter.velocity = ((target.position - shooter.position).normalized() * GRAPPLE_FORCE*PLAYER_OBJECT_WEIGHT_RATIO)
		target.constant_force = ((shooter.position - target.position).normalized() * GRAPPLE_FORCE*(1-PLAYER_OBJECT_WEIGHT_RATIO))
		# Stretch rope between player and target
		look_at(target.position)
		scale.z = (target.position - shooter.position).length()

func _on_player_released_fire() -> void:
	## TODO Ignore for a short timer so player can click to shoot, and click to release
	kill_process = true
	if target: if target is RigidBody3D: target.constant_force -= target.constant_force
	queue_free()
