extends Area2D 

@export_range(0,2) var egg_id: int = 0 ## id of which egg in the level this one is.

signal egg_collected(egg_id: int)
signal egg_disappeared(egg_id: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Checks if players wings collided with egg
func _on_body_entered(body):
	if body.is_in_group("Player"):
		collect_egg()

## Check if players cockpit collided with egg
func _on_area_entered(area):
	if area.get_owner().is_in_group("Player"):
		collect_egg()

## emits signal with self's egg_id and destroys self TODO: do animation? maybe handle in level controller
func collect_egg():
	$AnimationPlayer.play("egg_collected")
	egg_collected.emit(egg_id)
	#queue_free()

func emit_egg_disappeared_signal():
	egg_disappeared.emit(egg_id)
