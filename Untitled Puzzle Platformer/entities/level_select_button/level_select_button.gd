class_name LevelSelectButton
extends TextureButton

signal stat_update_finished()
signal unlock_finished()

@export var category: Enums.LevelTypes 
@export var world: int = 0
@export var level: int = 0

@export var level_ref: LevelData ## Data containing medal times and uid of this level
@export var pre_reqs: Array[Vector2i] ## [World, Level] a list of all levels that must be completed to unlock this level

@onready var _key = Vector3i(category, world, level)
var _level_data: LevelPlayerData ## Data containing the players stats of this level

func _ready():
	$Label.hide()
	$Label.text = str(world) + "-" + str(level)
	
	get_player_stats()
	
	## Display players data
	if _level_data != null:
		$Label.text += ":)"
		$Label2.text = "eggs: " + str(_level_data.eggs)
		%OverworldEgg1.visible = _level_data.eggs[0]
		%OverworldEgg2.visible = _level_data.eggs[1]
		%OverworldEgg3.visible = _level_data.eggs[2]
		%OverworldFeather.visible = _level_data.hits == 0
		if _level_data.hits == 0:
			$Label3.text = "P: yerp"
		pass
	
	## If all pre req levels are not completed, hide the button.
	for pre_req in pre_reqs:
		if GlobalStats.data.levels.has(Vector3i(category, pre_req.x, pre_req.y)):
			if GlobalStats.data.levels[Vector3i(category, pre_req.x, pre_req.y)].completed == false:
				hide()
				break
		else:
			hide()
			break

## Get's the players stats and stores them
func get_player_stats():
	if GlobalStats.data.levels.has(_key):
		_level_data = GlobalStats.data.levels[_key]

## Called when player returns to level select after completing a level
func update_stats():
	# store reference to old record
	var old_data: LevelPlayerData = _level_data
	get_player_stats()
	
	# as of right now all level buttons have their update_stats func called after each level, 
	# should filter to just the level completed. 
	if _level_data == null:
		stat_update_finished.emit()
		return
	
	#TODO: add animations and sounds here 
	if old_data == null:
		$Label2.text = "eggs: " + str(_level_data.eggs)
		%OverworldEgg1.visible = _level_data.eggs[0]
		%OverworldEgg2.visible = _level_data.eggs[1]
		%OverworldEgg3.visible = _level_data.eggs[2]
		%OverworldFeather.visible = _level_data.hits == 0
		if _level_data.hits == 0:
			$Label3.text = "P: yerp"
		$Label.text = str(_level_data.best_time)
	else:
		if _level_data.eggs.count(true) > old_data.eggs.count(true):
			print("new egg record")
			%OverworldEgg1.visible = _level_data.eggs[0]
			%OverworldEgg2.visible = _level_data.eggs[1]
			%OverworldEgg3.visible = _level_data.eggs[2]
			$Label2.text = "eggs: " + str(_level_data.eggs)
		
		if _level_data.hits == 0 and old_data.hits != 0:
			%OverworldFeather.visible = true
			print("perfected!")
			$Label3.text = "P: yerp"
		
		if _level_data.best_time < old_data.best_time:
			$Label.text = str(_level_data.best_time)
	
	
	

	stat_update_finished.emit()

## plays unlocking animation, called when all prereq levels are completed
func unlock():
	if visible:
		unlock_finished.emit()
		return
		
	for pre_req in pre_reqs:
		if GlobalStats.data.levels.has(Vector3i(category, pre_req.x, pre_req.y)):
			if GlobalStats.data.levels[Vector3i(category, pre_req.x, pre_req.y)].completed:
				show()
	unlock_finished.emit()

func _on_pressed():
	SceneManager.load_sub_scene(level_ref.level_uid, get_tree().current_scene, {"world": world, "level": level, "category": category})
	#SceneManager.swap_scene(level_ref.level_uid, self, \
		#{"world": world, "level": level, "category": category}) #level_ref.level_ref, "foobar")


func _on_mouse_entered():
	grab_focus()
	$Label.show()
	pass # Replace with function body.


func _on_mouse_exited():
	$Label.hide()
	pass # Replace with function body.
