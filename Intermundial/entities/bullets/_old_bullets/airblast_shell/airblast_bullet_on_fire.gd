extends BulletEffect

const BLAST_FORCE:float = 0.5
const PLAYER_POPUP:float = 0.14

func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	## TODO: Blast direction should be supplied by the bullet
	var blast_direction:Vector3 = Collections.get_player().get_facing_direction()
	Collections.get_player().velocity.y += PLAYER_POPUP
	Collections.get_player().velocity += blast_direction.normalized() * BLAST_FORCE
