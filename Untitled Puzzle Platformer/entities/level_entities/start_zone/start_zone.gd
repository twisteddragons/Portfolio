extends SafeZone

signal leave_start()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_exited(area):
	super(area)
	if area.get_owner().is_in_group("Player"):
		leave_start.emit()
