extends Node2D

@export var music_package: MusicPackage
@export var level_ref: LevelData ## other data relating to this level that is accessed elsewhere when not loaded in, contains medal times

var category: Enums.LevelTypes ## What category this world level combo is from
var world: int = 0 ## What world this level belongs to
var level: int = 0 ## What level in the world this level is
var old_stats: LevelPlayerData = LevelPlayerData.new() ## the players previous best stats, is a new instance if it is the first playthrough

var time: float = 0.0 ## time spent on this level, starts when player leaves start zone
var eggs: Array[bool] = [false, false, false] ## which eggs have been collected
var hits: int = 0 ## number of times the player has been hit

var level_select_uid = "uid://bk7ly2eupg5ly"


func _ready():
	MusicHandler.play_package(music_package)
	
	## Set up player
	#player.position = start_zone.position ## position player perfectly in start zone center
	%Player.invincible = true
	# TODO: change players skin/colour
	
	var safe_zones = get_tree().get_nodes_in_group("safe_zone")
	for safe_zone in safe_zones:
		safe_zone.enter_checkpoint.connect(%Player._on_safe_zone_enter_checkpoint)
		safe_zone.leave_checkpoint.connect(%Player._on_safe_zone_leave_checkpoint)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			%PauseMenu.hide()
		else:
			get_tree().paused = true
			%PauseMenu.show()

func receive_data(data: Dictionary):
	world = data["world"]
	level = data["level"]
	category = data["category"]

## called after data is passed via receive_data
func init_scene():
	## get old stats of level or, if first time playing, default stats
	var key: Vector3i = Vector3i(category, world, level)
	if GlobalStats.data.levels.has(key):
		old_stats = GlobalStats.data.levels[key]

func start_scene():
	pass

func end_level():
	%Player.invincible = true
	## Move player to center of the end zone
	var tween = get_tree().create_tween()
	tween.tween_property(%Player, "position", %EndZone.position, 0.5)
	
	## update player record for this level
	var new_stats = LevelPlayerData.new()
	
	new_stats.completed = true
	
	## if this is the players first time beating the level,
	if old_stats.completed == false:
		new_stats.hits = hits
		new_stats.best_time = time
		new_stats.eggs = eggs
		new_stats.medal = get_medal(time)
	else: ## if this is NOT the players first time beating the level, update relevant stats
		new_stats.hits = min(hits, old_stats.hits)
		new_stats.best_time = min(time, old_stats.best_time)
		## NOTE: i think there is a bug with Godot where directly assigning the rhs array gives an error (maybe a feature?)
		## I think it's because new_stats.eggs is of type Array[bool] and the rhs isn't explicitly stated as such
		## The reason the bug doesn't happen for the assignment above is because eggs is also explicitely typed
		## Either way, use assign() instead
		new_stats.eggs.assign([eggs[0] or old_stats.eggs[0], eggs[1] or old_stats.eggs[1], eggs[2] or old_stats.eggs[2]])
		new_stats.medal = max(get_medal(time), old_stats.medal)
	
	## push stats to GlobalStats
	var key: Vector3i = Vector3i(category, world, level)
	GlobalStats.data.levels[key] = new_stats
	
	## save game
	SaveHandler.save_game()
	
	## TODO: check if tween exists first
	await tween.finished
	
	## TODO: Go back to level select or show end menu or smth idk 
	SceneManager.exit_sub_scene(self, {"level_completed": true})
	#SceneManager.swap_scene(level_select_uid, self)

## given a time, returns which medal it would earn with 3 being gold, 2 silver, 1 bronze, and 0 none
func get_medal(time: float) -> int:
	if time < level_ref.gold_time:
		return 3
	elif time < level_ref.silver_time:
		return 2
	elif time < level_ref.bronze_time:
		return 1
	return 0 


func _on_egg_egg_collected(egg_id: int):
	eggs[egg_id] = true


func _on_end_zone_level_finished():
	end_level()


func _on_player_took_damage():
	if hits == 0:
		%LevelHud._on_player_took_damage()
	hits += 1


func _on_start_zone_leave_start():
	#TODO: start timer
	pass # Replace with function body.


func _on_player_player_died():
	SceneManager.restart_scene()
