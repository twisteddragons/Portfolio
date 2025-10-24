class_name BasicRoom
extends Node3D

## avalible combat points for specific room, only used in random spawns
@export var room_combat_value : float

var enemy_spawn_avalible : bool = true
var Player_respawn_point : Node

#initilize called by the room generator
func initilize():
	# get refrence to respawn point
	var respawn_point = get_node("CheckPoint")
	if respawn_point:
		Player_respawn_point = respawn_point
	else:
		print("no checkpoint found")




func on_room_entered(node):
	if node.is_in_group(Collections.GLOBAL_GROUPS.PLAYER):
		if enemy_spawn_avalible:
			spawn_enemies()


func spawn_enemies():
	enemy_spawn_avalible = false
	print("spawned en")
	for child in %SpawnPoints.get_children():
		if child is EnemySpawn:
				child.spawn_enemy()

## needs rework
#func config_doors():
	#for child in get_children():
		#if child is Door:
			#child.position += global_position
			#child.config()


func _on_checkpoint_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(Collections.GLOBAL_GROUPS.PLAYER):
		print("checkpoint_set")
		RespawnManager.last_active_checkpoint = Player_respawn_point
