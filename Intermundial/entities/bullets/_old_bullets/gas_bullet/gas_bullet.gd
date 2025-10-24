extends BulletEffect

const GAS_PATH:String = "res://entities/effect_entities/gas_cloud/GasCloud.tscn"

func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	var gas_entity:PackedScene = load(GAS_PATH)
	for p in Collections.stat_tracker.player_last_hitscan_positions:
		var e = gas_entity.instantiate()
		e.global_position = p
		Util.get_effect_entity_node().add_child(e)
	return
