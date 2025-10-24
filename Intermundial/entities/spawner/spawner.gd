extends Node3D
## all purpose spawner, mostly for testing

@onready var spawn_timer: Timer = $Spawn_timer


@export var Item: PackedScene 

@export var spawn_delay : float = 1.0
@export var max_items : int = 0    # if set to 0 spawns items forever
@export var item_lifetime : float = 10.0

var spawned_items : Array = []

func _ready() -> void:
	spawn_timer.wait_time = spawn_delay
	spawn_timer.start()

func _on_timer_timeout() -> void:
	if max_items > 0 and spawned_items.size() >= max_items:
		return
	
	var new_item = Item.instantiate()
	add_child(new_item)
	
	#adds the item to da array
	spawned_items.append(new_item)
	
	if item_lifetime > 0:
		await get_tree().create_timer(item_lifetime, false).timeout
		# safty check
		if is_instance_valid(new_item) and new_item in spawned_items:
			remove_item(new_item)

func remove_item(item : Node):
	print("removing")
	#removes from array
	if item in spawned_items:
		spawned_items.erase(item)
	# deletes object
	if is_instance_valid(item) and item.is_inside_tree():
		item.queue_free()
