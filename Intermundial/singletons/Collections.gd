extends Node

## Contains all available bullet types
#enum BULLET_TYPES{BASIC, DEV, GAS, SHOTGUN_SHELL, TELEPORT, GRAPPLE, AIRBLAST_SHELL, SNIPER, BASIC_PROJECTILE}
enum BULLET_TYPES{BASIC, SHOTGUN_SHELL, SNIPER, BASIC_PROJECTILE}

## Contains UID to SpecialBullet resources
const BULLET_RESOURCES:Dictionary = {
	BULLET_TYPES.BASIC: "uid://dqdk2b68n63w8",
	#BULLET_TYPES.DEV: "uid://cckqlswr24ra5",
	#BULLET_TYPES.GAS: "uid://bwb4iyekfm76w",
	BULLET_TYPES.SHOTGUN_SHELL: "uid://bywy2bd7wtnck",
	#BULLET_TYPES.TELEPORT: "uid://bq4vyemn0j7f8",
	#BULLET_TYPES.GRAPPLE: "uid://15cdhwhqbw22",
	#BULLET_TYPES.AIRBLAST_SHELL: "uid://b42l5ev532gn8",
	BULLET_TYPES.SNIPER: "uid://b0hwh1bpnk81b",
	BULLET_TYPES.BASIC_PROJECTILE: "uid://djk50yu4d20c5"
}
@onready var bullet_scene:PackedScene = preload("uid://cgicsjrgenlbl")
@onready var projectile_scene:PackedScene = preload("uid://di1oimjhqtjx")

## Contains all available fire types
enum FIRE_TYPES{SINGLE_HITSCAN, CLUSTER_HITSCAN, PROJECTILE}

## To be used like `print(Collections.get_bullet_type(bullet.bullet_type)`;
## just translates enum into string.
func get_bullet_type(type:int) -> String:
	return BULLET_TYPES.keys()[type]

## Some default floats for projectile gravity. These are in degrees of rotation
## per frame * delta; projectiles travel in one direction, but can be rotated.
## NOTE: These were gathered while speed = 70.0
const PROJECTILE_GRAVITY_SCALES:Dictionary = {
	"LIGHT": 0.5,
	"MEDIUM": 1.0,
	"HEAVY": 2.0
}

## Contains group names
const GLOBAL_GROUPS:Dictionary = {
	"DAMAGEABLE": "Damageable",
	"EFFECTABLE": "Effectable",
	"PLAYER": "Player",
	"ENEMY": "Enemy"
}

## Returns a group in the tree - helpful for objects (like bullets) outside of the tree
func get_group(group:String) -> Array[Node]:
	return get_tree().get_nodes_in_group(group)
	
## Quickly return the player
func get_player() -> Node:
	return get_group(GLOBAL_GROUPS.PLAYER)[0]

## Stat tracker - contains helpful data for item and bullet effects
var stat_tracker: Dictionary  = {
	"cylinder_size": 6,
	"starting_cylinder_pattern": [BULLET_TYPES.BASIC, BULLET_TYPES.BASIC, BULLET_TYPES.BASIC_PROJECTILE, BULLET_TYPES.SHOTGUN_SHELL, BULLET_TYPES.SHOTGUN_SHELL, BULLET_TYPES.SNIPER],
	"player_last_hitscan_positions": [],
	"player_funds": 0
}
''' BULLET TRACKING WORKFLOW
####################################################################
		NOTE: DO NOT UNCOMMENT THIS SECTION. IT IS NOT CODE.
####################################################################
weapon_manager._ready() ->
	sets cylinder_contents based on stat_tracker.starting_cylinder_pattern
	add_bullet()s a few basic bullets into the bullet_pouch_contents
	refresh_cylinder()s to set up the chambers to reflect cylinder_contents

weapon_manager._try_fire() ->
	queue_free()s the scene (leaves null instance in cylinder_contents)

weapon_manager._try_reload() ->
	starts "reload_start" animation
	
weapon_manager._on_animation_finished("reload_start") ->
	starts "reload_end" animation
	does do_reload()

weapon_manager.do_reload() ->
	empties null instances (all instances) from cylinder_contents
	calls Collections.load_random_bullet() 6 times
	refresh_cylinder()s
	
Collections.load_random_bullet() ->
	if no bullets in pouch, copies full_bullet_reserve into bullet_pouch_contents, then deletes any duplicate bullets already in cylinder_contents
	randomly pops a bullet from pouch and puts into cylinder_contents
'''

signal bullet_pouch_restocked
signal bullet_reloaded
signal bullet_created
var cylinder_contents:Array[Bullet] = []
var bullet_pouch_contents:Array[Bullet] = []
var full_bullet_reserve:Array[Bullet] = []

## Instantiates the bullet and puts it into proper collections
func add_bullet(bullet_type:BULLET_TYPES, directly_to_cylinder:bool=false) -> void:
	var b = bullet_scene.instantiate()
	b.bullet_resource = load(BULLET_RESOURCES[bullet_type])
	if directly_to_cylinder: cylinder_contents.push_back(b)
	else: bullet_pouch_contents.push_back(b)
	full_bullet_reserve.push_back(b.duplicate())
	emit_signal("bullet_created")

## Go through pouch and pull a random bullet into the cylinder
func load_random_bullet() -> bool:
	# Refill pouch if empty
	if not bullet_pouch_contents:
		Util.deep_copy_a_into_b(full_bullet_reserve, bullet_pouch_contents)
		# Remove any bullets that are already loaded into the cylinder
		for b in cylinder_contents:
			var loaded_type = b.get_bullet_type()
			for pouch_bullet in bullet_pouch_contents:
				if pouch_bullet.get_bullet_type() == loaded_type:
					bullet_pouch_contents.erase(pouch_bullet)
					break
		emit_signal("bullet_pouch_restocked")
	# Confirm a bullet can be loaded
	if cylinder_contents.size() >= stat_tracker.cylinder_size:
		return false
	# Pick a random bullet in the pouch
	cylinder_contents.push_back(bullet_pouch_contents.pop_at(randi()%bullet_pouch_contents.size()))
	emit_signal("bullet_reloaded")
	return true
