extends BulletEffect

const BLAST_FORCE:float = 1.5
const BLAST_FALLOFF:float = 4.5

func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	## TODO: Blast direction should be supplied by the bullet
	var blast_direction:Vector3 = Collections.stat_tracker.player_last_hitscan_positions[0] -\
		Collections.get_player().position
	if caller:
		var launch_power:float = max((-blast_direction.length()) + BLAST_FALLOFF, 0.0) * BLAST_FORCE
		if caller.has_method("apply_impulse"): caller.apply_central_impulse(blast_direction.normalized() * launch_power)
