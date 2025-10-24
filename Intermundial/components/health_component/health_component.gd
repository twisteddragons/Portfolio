class_name HealthComponent
extends Node3D

signal health_changed(old_health: int, new_health: int)
signal died()

@export var max_health: int = 100
@export var health_bar: bool = true
#@export var enemy_weakness: 

func _ready() -> void:
	
	if health_bar:
		%Healthbar.visible = true
		%HealthProgress.value = health
	else:
		%Healthbar.visible = false

var health: int = 100:
	set(value):
		var old_health = health
		health = min(value, max_health)
		health_changed.emit(old_health, health)
		if old_health > 0 and health <= 0:
			died.emit()
		%HealthProgress.value = health

var alive: bool:
	get:
		return health > 0
var damaged: bool:
	get:
		return health < max_health
var health_percent: float:
	get:
		return float(health)/max_health

func heal(amount: int):
	health += amount

func damage(amount: int):
	health -= amount
