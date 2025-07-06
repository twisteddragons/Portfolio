## Players stats for a level, how well they did
class_name LevelPlayerData
extends Resource

@export var hits: int = -1 ## lowest amount of hits taken for a level
@export var eggs: Array[bool] = [false, false, false] ## which eggs have been collected
@export var best_time: float = -1.0 ## best time for a level
@export var medal: int = -1 ## medal earned for this level
@export var completed: bool = false ## whether or not this level has been completed
