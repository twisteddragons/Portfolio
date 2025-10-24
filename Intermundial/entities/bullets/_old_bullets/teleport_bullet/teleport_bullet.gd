extends BulletEffect

const POP_UP:float = 2.0  # How high to pop the player at the teleport location

var player:CharacterBody3D

func _init() -> void:
	player = Collections.get_group(Collections.GLOBAL_GROUPS.PLAYER)[0]

func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	assert(player, "Player has not been initialized")
	for p in Collections.stat_tracker.player_last_hitscan_positions:
		player.global_position = Vector3(p.x, p.y + POP_UP, p.z)
		## TODO Create a puff effect where the player was and where they appear
		break
	return
