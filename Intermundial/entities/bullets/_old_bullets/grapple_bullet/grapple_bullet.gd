extends BulletEffect

const GRAPPLE_PATH:String = "res://entities/effect_entities/grapple/Grapple.tscn"

@onready var grapple_entity:PackedScene = preload(GRAPPLE_PATH)


func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	if not grapple_entity: grapple_entity = load(GRAPPLE_PATH)
	var e = grapple_entity.instantiate()
	# Configure entity
	e.shooter = Collections.get_group(Collections.GLOBAL_GROUPS.PLAYER)[0]
	if caller is RigidBody3D:	e.target = caller
	else: e.target = Collections.stat_tracker.player_last_hitscan_positions[0]
	Collections.get_group(Collections.GLOBAL_GROUPS.PLAYER)[0]\
		.player_action_released_fire.connect(Callable(e, "_on_player_released_fire"))
	# Add to tree
	Util.get_effect_entity_node().add_child(e)
	return
