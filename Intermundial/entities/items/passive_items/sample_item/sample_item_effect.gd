class_name SampleItemEffect
extends ItemEffect



# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_tree().get_nodes_in_group("Player"):
		if child is Player:
			child.jump.connect(execute)
	pass # Replace with function body.


func execute():
	super()
	%FunnySound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
