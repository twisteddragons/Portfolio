class_name SaveFile
extends Resource

@export var levels: Dictionary[Vector3i, LevelPlayerData] ## (category: Enums.LevelTypes, world, level) : data
#var main_levels : Dictionary[Vector2i, LevelPlayerData] ## (world, level) : data
#var bonus_levels : Dictionary[Vector2i, LevelPlayerData] ## (world, level) : data
@export var cutscene_flags: Dictionary[String, bool] = {
	"intro": false
}
## what the player has equipped
@export var equipped_cosmetics: Dictionary[String, String] = {
	"wings": "base",
	"cockpit": "base",
	"palette": "base"
}
## if a cosmetic is in here, it is unlocked, otherwise it is locked
@export var unlocked_cosmetics: Dictionary[String, Array] = {
	"wings": ["base"],
	"cockpit": ["base"],
	"palette": ["base"]
}
