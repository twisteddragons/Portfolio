extends Node #TODO: extend correct node type

# meta-name: Scene Manager Functionality
# meta-description: contains functions to enable support for SceneManager singleton
# meta-default: true
# meta-space-indent: 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# if the previous scene passed any data, it will get received here
func receive_data(data):
	print(data)

# Called after scene receives data, before start_scene. The loading screen is still present at this point
func init_scene():
	pass 

# Called after init_scene. The loading screen is gone at this point
func start_scene(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
