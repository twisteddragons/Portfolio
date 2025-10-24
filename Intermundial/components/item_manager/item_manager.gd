class_name ItemManager
extends Node3D

@export var _items: Array[ItemResource] ## do not access directly, add and remove with add_item() and remove_item()

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in _items:
		attach_item_effect(item)

func add_item(item: ItemResource):
	_items.append(item)
	attach_item_effect(item)

func remove_item(item: ItemResource):
	for i in _items.size():
		if _items[i] == item:
			_items.remove_at(i)
			remove_item_effect(item)

##if the item has an effect_scene, attach it, otherwise does nothing
func attach_item_effect(item: ItemResource):
	if item.effect_scene:
		var item_scene: ItemEffect = item.effect_scene.instantiate()
		item_scene.item_owner = owner
		item_scene.item_resource_reference = item
		print(owner)
		add_child(item_scene)

## NOTE: might cause bugs in the case of having two of the same item, especially if they're distinct somehow (spare pants joker)
func remove_item_effect(item: ItemResource):
	if item.effect_scene:
		# get the script of the scene being remove to compare to children scripts
		# almost certain this is scuffed and there's a better way
		var item_effect = item.effect_scene.instantiate()
		var item_script = item_effect.get_script()
		item_effect.queue_free()
		
		for child in get_children():
			if child.get_script() == item_script:
				child.queue_free()
