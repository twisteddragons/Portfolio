class_name EnemySpawn
extends Node3D

@export var enemy : PackedScene

func spawn_enemy():
	print("spawning enemy")
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
