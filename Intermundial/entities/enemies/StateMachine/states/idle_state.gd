@tool
extends State
class_name IdleState

func _ready():
	self_root = self_root as BaseEnemy
	pass

func state_processing(delta: float):
	pass
	#print("idling")
