class_name MoonBoots
extends ItemEffect



# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_tree().get_nodes_in_group("Player"):
		if child is Player:
			var kick = child.find_child("kick")
			kick.player_kicked_object.connect(execute)
			# I wanna connect this to when the player kicks the ground
	pass # Replace with function body.


func execute():
	super()
	%BounceSound.play()
	# Take the kick direction (to be passed by the signal) and send the player in the opposite direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
