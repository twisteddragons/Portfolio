extends Button

signal keybind_button_pressed(source: Button, action: String)
@export var action: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	keybind_button_pressed.emit(self, action)
