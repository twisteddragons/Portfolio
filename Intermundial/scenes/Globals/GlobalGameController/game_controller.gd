class_name GameController
extends Node

## Scene manager for loading / unloading 
# stolen from : https://www.youtube.com/watch?v=32h8BR0FqdI

@export var world_3d : Node3D
@export var world_2d : Node2D
@export var gui : Control

#currently loaded scene
var current_3d_scene
var current_2d_scene
var current_gui_scene



# sets refrence in global
func _init() -> void:
	Global.game_controller = self
	

func _ready() -> void:
	#starting screen (splash)
	change_gui_scene("uid://cpjma2qwnm5dp")

# manager for 3d scene
func change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false ):
	if current_3d_scene != null: # if there is a pre-existing scene determin what to do with it
		if delete:
			current_3d_scene.queue_free() # removes scene
		elif keep_running:
			current_3d_scene.visible = false #keep in memory and running
		else:
			gui.remove_child(current_3d_scene) #keep in memory not running
	
	var new = load(new_scene).instantiate() # loads new scene
	world_3d.add_child(new)
	current_3d_scene = new


# manager for 2d scene
func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false ):
	if current_2d_scene != null: # if there is a pre existing scene determin what to do with it
		if delete:
			current_2d_scene.queue_free() # removes scene
		elif keep_running:
			current_2d_scene.visible = false #keep in memory and running
		else:
			gui.remove_child(current_2d_scene) #keep in memory not running
	
	var new = load(new_scene).instantiate() # loads new scene
	world_2d.add_child(new)
	current_2d_scene = new


# manager for gui
func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false ):
	if current_gui_scene != null: # if there is a pre existing scene determin what to do with it
		if delete:
			current_gui_scene.queue_free() # removes scene
		elif keep_running:
			current_gui_scene.visible = false #keep in memory and running
		else:
			gui.remove_child(current_gui_scene) #keep in memory not running
	
	var new = load(new_scene).instantiate() # loads new scene
	gui.add_child(new)
	current_gui_scene = new

# remove scene without replacing it
func remove_gui_scene():
	if current_gui_scene != null:
		current_gui_scene.queue_free()

func remove_3d_scene():
	if current_3d_scene != null:
		current_3d_scene.queue_free()
