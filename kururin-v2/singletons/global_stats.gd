extends Node

var data : SaveFile = SaveFile.new()

func _ready():
	#data.main_levels[Vector2i(1,1)] = LevelSaveData.new()
	SaveHandler.load_game()
	#print(data.main_levels[Vector2i(1,1)].completed)
	#SaveHandler.load_game()
