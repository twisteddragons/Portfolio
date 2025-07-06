extends Control

@export var cockpit_name: String = "base"
@onready var cockpit_ref: Texture2D = load("res://entities/player/art/cockpits/" + cockpit_name + ".png")

signal cockpit_chosen(cockpit_name: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	%TextureButton.pivot_offset = %TextureButton.size/2 ## center the buttons pivot
	%TextureButton.texture_normal = cockpit_ref


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	cockpit_chosen.emit(cockpit_ref)
	#TODO: play noise


func _on_texture_button_mouse_entered():
	$CockpitBody/TextureButton.scale = Vector2(1.3, 1.3)


func _on_texture_button_mouse_exited():
	$CockpitBody/TextureButton.scale = Vector2(1, 1)
