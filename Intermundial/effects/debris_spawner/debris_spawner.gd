extends Node
## debris spawner, attach to a breakable object and use spawn_debris()
## need to add limit or lifetime to spawned objects for performace.
## need to remove this node after all spawned objects are gone to prevent buildup.

@onready var break_sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var break_particles: GPUParticles3D = $break_particles

@export var debris_scene: PackedScene
@export var spawn_count: int = 5
@export var min_force: float = 2.0
@export var max_force: float = 8.0


func _ready() -> void:
	call_deferred("spawn_debris")

func spawn_debris():
	break_sfx.play()
	break_particles.emitting = true
	
	# adds da debris as child
	for i in range(spawn_count):
		var debris: RigidBody3D = debris_scene.instantiate()
		add_child(debris)
		
		#random direction
		var force_dir = Vector3(
		randf_range(-1, 1),
		randf_range(0.5, 1), 
		randf_range(-1, 1)
		).normalized()
		
		var force = randf_range(min_force, max_force)
		debris.apply_central_impulse(force_dir * force)
	
	
