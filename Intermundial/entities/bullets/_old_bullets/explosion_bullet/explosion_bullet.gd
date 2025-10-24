extends BulletEffect

const EXPLOSION_PATH:String = "res://entities/effect_entities/explosion/Explosion.tscn"

func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	var explosion_entity:PackedScene = load(EXPLOSION_PATH)
	for p in Collections.stat_tracker.player_last_hitscan_positions:
		var e = explosion_entity.instantiate()
		e.radius = 2
		e.force = 15
		e.global_position = p
		Util.get_effect_entity_node().add_child(e)
	return
