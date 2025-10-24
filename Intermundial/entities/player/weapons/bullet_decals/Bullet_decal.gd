class_name BulletDecalPool

const MAX_DECALS = 40
static var decal_pool := []

static func spawn_bullet_decal(global_pos : Vector3 ,normal : Vector3, parent : Node3D ):
	var decal_instance : Node3D
	if len(decal_pool) >= MAX_DECALS and is_instance_valid(decal_pool[0]):
		decal_instance = decal_pool.pop_front()
		decal_pool.push_back(decal_instance)
		decal_instance.reparent(parent)
	else:
		decal_instance = preload("uid://8fm65mqx7oun").instantiate()
		parent.add_child(decal_instance)
		decal_pool.push_back(decal_instance)
	
	if not is_instance_valid(decal_pool[0]):
		decal_pool.pop_front()
	
	decal_instance.global_transform = Transform3D(Quaternion(Vector3.UP,normal),global_pos)
	decal_instance.get_node("GPUParticles3D").emitting = true
