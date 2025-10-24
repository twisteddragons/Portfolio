class_name ItemEffect
extends Node

# The logic for the effect when it is in game and attached to an entity. e.g. the player
# can really be attached to anything, you just have to handle the cases when defining an item

signal item_triggered(item)

# owner is a key word in godot, cant use that
var item_owner: Node
var item_resource_reference: ItemResource

func _init():
	add_to_group("items")

func execute():
	item_triggered.emit(self)
	pass
