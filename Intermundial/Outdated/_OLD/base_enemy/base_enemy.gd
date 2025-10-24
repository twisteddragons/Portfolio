class_name BaseEnemy
extends CharacterBody3D

signal health_changed(old_value: int, new_value: int)
signal died()

@export var health: int = 100:
	set(value):
		var old_health = health
		health = value
		health_changed.emit(old_health, health)
#@export var MoveSpeed: float = 10.0
@export var hitsound: AudioStreamPlayer3D 

var in_combat: bool = false

@onready var movement_target: Vector3 = position
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func take_damage(amount: int):
	health -= amount

func die():
	died.emit()
	queue_free()
	pass
