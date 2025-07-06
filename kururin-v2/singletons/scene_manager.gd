extends Node

## TODO: some functionality could be put into more detailed functions to help reuse
## e.g. the recieve_data, init_scene, and start_scene combo

signal load_start(loading_screen) # triggered when an asset begins loading
signal scene_added(loading_scene: Node, loading_screen) # triggered right after asset is added to SceneTree but before it begins loading
signal load_complete(loaded__scene: Node) # triggered when loading has completed
signal _content_finished_loading(content)

var _loading_in_progress: bool = false ## used to block SceneManager from loading multiple scenes at once
var _loading_screen_scene: PackedScene = preload("uid://c3rsjljvelids")
var _loading_screen: LoadingScreen ## contains reference to loading screen
var _content_uid: String = "uid://dd8jiw2spnc1g" ## Stores uid of scene SceneManager is attempting to load
var _parent_node_stack: Array[Node] = [] ## In case the player enters one or more "sub-areas", Stack to keep track of parent areas
var _parent_process_mode_stack: Array = []
var _load_progress_timer: Timer ## Used to check in on load progress
var _scene_to_unload: Node
var _load_scene_into: Node
var _data_to_pass ## Data passed from current scene to next scene

func _ready() -> void:
	SceneManager._content_finished_loading.connect(_on_content_finished_loading)

func swap_scene(scene_to_load: String, scene_to_unload: Node = null, data = null, load_into: Node = get_tree().root, transition_library: String = "fade") -> void:
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	
	_loading_in_progress = true
	#if load_into == null: load_into = get_tree().root # NOTE: I dont think we can make this a default param due to how get_tree works????
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload
	_data_to_pass = data
	
	
	await _add_loading_screen(transition_library) 
	get_tree().paused = false 
	# won't start loading until the loading screen has fully transitioned in
	_load_content(scene_to_load)

## Exit current scene but keep said scene in tree and memory to return to later using "exit_sub_scene()"
func load_sub_scene(scene: String, scene_to_save: Node, data = null, load_into: Node = get_tree().root, transition_library: String = "fade"):
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	
	
	_parent_node_stack.push_back(scene_to_save) ## save parent in stack
	
	swap_scene(scene, null, data, load_into, transition_library)
	## ensure node doesn't disappear until the loading screen has fully covered screen.
	await _loading_screen.anim_player.animation_finished
	
	get_tree().root.remove_child(scene_to_save) ## remove parent from tree

## Exit current scene and go to "parent" scene
func exit_sub_scene(scene_to_unload: Node = null, data = null, load_into: Node = get_tree().root, transition_library: String = "fade"):
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	
	_loading_in_progress = true
	
	if _parent_node_stack.size() == 0:
		printerr("Error: attempted to exit child scene when no parent scene exists")
		return
	var parent: Node = _parent_node_stack.pop_back()
	
	
	await _add_loading_screen()
	
	## Make current scene the parent scene
	get_tree().root.add_child(parent)
	get_tree().current_scene = parent
	
	if parent.has_method("receive_data"):
		parent.receive_data(data)
		
	## Remove child scene
	if scene_to_unload != null:
		if scene_to_unload != get_tree().root:
			scene_to_unload.queue_free()
	
	if parent.has_method("init_scene"):
		parent.init_scene()
		
	get_tree().paused = false 
	_loading_screen.finish_transition()
	
	if parent.has_method("start_scene"):
		parent.start_scene()
	_loading_in_progress = false

## restarts the current scene with a loading screen. 
func restart_scene(pass_data: bool = true):
	await _add_loading_screen()
	get_tree().paused = false 
	get_tree().reload_current_scene() ## TODO: figure out how to do this with ResourceLoader, right now the loading screen bar will not update.
	
	await get_tree().node_added
	if get_tree().current_scene.has_method("receive_data") and pass_data and _data_to_pass != null:
		get_tree().current_scene.receive_data(_data_to_pass)
	
	if get_tree().current_scene.has_method("init_scene"):
		get_tree().current_scene.init_scene()
	
	_remove_loading_screen()
	
	if get_tree().current_scene.has_method("start_scene"):
		get_tree().current_scene.start_scene()

## returns whether or not there is a parent scene.
func parent_scene_exists() -> bool:
	return _parent_node_stack.size() > 0

func _add_loading_screen(transition_library: String = "fade"):
	_loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(_loading_screen)
	_loading_screen.start_transition(transition_library)
	await _loading_screen.anim_player.animation_finished
	#print("screen added")

func _remove_loading_screen():
	if _loading_screen != null:
		_loading_screen.finish_transition()

func _load_content(scene_uid: String):
	#print("_load_content begin")
	load_start.emit(_loading_screen) # copied from tutorial, unsure what its for
	
	_content_uid = scene_uid
	var loader = ResourceLoader.load_threaded_request(scene_uid)
	if not ResourceLoader.exists(scene_uid) or loader == null:
		push_error("ERROR: scene passed to SceneMager to load does not exist")
		return
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(_monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()
	print("_load_content end")
	

func _monitor_load_status() -> void:
	print("checking load status")
	var load_progress: Array[float] = [] # needs to be array due to how load_threaded_get_status works
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_content_uid, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_load_progress_timer.stop()
			printerr("ERROR: THREAD_LOAD_INVALID_RESOURCE")
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			#print("LOAD IN PROGRESS")
			if _loading_screen != null:
				_loading_screen.update_progress(load_progress[0])
		ResourceLoader.THREAD_LOAD_FAILED:
			_load_progress_timer.stop()
			printerr("ERROR: THREAD_LOAD_FAILED")
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			#print("LOAD SUCCESS")
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			_content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_uid).instantiate())
			return

func _on_content_finished_loading(incoming_scene) -> void:
	if incoming_scene.has_method("receive_data"):
		incoming_scene.receive_data(_data_to_pass)
	
	scene_added.emit(incoming_scene, _loading_screen)
	
	_load_scene_into.add_child(incoming_scene)
	#_current_scene_ref = incoming_scene
	get_tree().current_scene = incoming_scene ## update sceneTree's current scene
	
	if _scene_to_unload != null and _scene_to_unload != get_tree().root:
		_scene_to_unload.queue_free()
			
	if incoming_scene.has_method("init_scene"):
		incoming_scene.init_scene()
	
	if _loading_screen != null:
		_loading_screen.finish_transition()
		# can comment this line to give play control while transition is in progress NOTE: incorrect, player has control either way
		# await _loading_screen.anim_player.animation_finished
	
	if incoming_scene.has_method("start_scene"):
		incoming_scene.start_scene()
	
	_loading_in_progress = false
	load_complete.emit(incoming_scene)
