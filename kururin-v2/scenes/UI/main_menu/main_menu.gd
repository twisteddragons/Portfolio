extends Control

@onready var menu_container: VBoxContainer = $VBoxContainer ## container for all buttons on main menu
@onready var play: Button = $VBoxContainer/Play ## Play button on main menu

@export var pointer: Sprite2D ## main menu visual pointer

func _ready():
	
	play.grab_focus()
	_on_focus_changed(play)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

## moves pointer to item that is in focus
func _on_focus_changed(item):
	if is_instance_valid(pointer) and is_instance_valid(item):
		pointer.global_position = Vector2(menu_container.global_position.x - pointer.texture.get_size().x * pointer.scale.x * .6, item.global_position.y + item.size.y * 0.5)

func _on_play_pressed():
	SceneManager.swap_scene("uid://bk7ly2eupg5ly", self)

func _on_settings_pressed():
	%SettingsMenu.visible = true
	pass

func _on_quit_pressed():
	#SaveHandler.save_game()
	get_tree().quit() 


func _on_delete_save_pressed():
	SaveHandler.delete_game()
	pass # Replace with function body.
