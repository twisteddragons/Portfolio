extends Node

@onready var effect_entities_group = get_tree().root.find_child("EffectEntitiesGroup", true, false)
@onready var projectile_entities_group = get_tree().root.find_child("BulletEntitiesGroup", true, false)

func get_effect_entity_node() -> Node3D:
	return effect_entities_group

func get_projectile_entity_node() -> Node3D:
	return projectile_entities_group

## Copies an array of object into another array with full duplicates of the objects
func deep_copy_a_into_b(a, b):
	for i in a:
		b.push_back(i.duplicate())
