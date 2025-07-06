extends Area2D

@export var dialogue_title: String = "error"
@export var NPC_name: String = "NA"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_dialogue():
	if Dialogic.current_timeline == null:
		Dialogic.start(dialogue_title)
