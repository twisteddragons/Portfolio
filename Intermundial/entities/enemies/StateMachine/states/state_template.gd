@tool
extends Node
class_name State
signal Transitioned(state:State, new_state_name: String)

var self_root: CharacterBody3D
var state_chart: StateChart

func _ready():
	self_root = owner

#func setup() -> void:
	#player = get_tree().get_first_node_in_group("Player")
	#self_root = get_parent().get_parent()
	#print("setup sucess")

func state_input(event: InputEvent):
	pass

func state_unhandled_input(event: InputEvent):
	pass

func state_entered():
	pass

func state_exited():
	pass

func state_processing(_delta: float) -> void:
	pass

func state_physics_processing(_delta: float) -> void:
	pass
