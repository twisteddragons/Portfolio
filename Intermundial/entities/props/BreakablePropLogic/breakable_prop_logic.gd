extends Node
## add to every physics prop

@export var health : float = 25.0
@export var debris_spawner : PackedScene

var broken:bool = false

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0 and not broken:
		broken = true  # Prevents overlapping a shit ton of sound effects
		break_prop()

func break_prop():
	if debris_spawner:
		
		var debris_spawn = debris_spawner.instantiate()  
		get_tree().root.add_child(debris_spawn)
		debris_spawn.global_position = self.global_position
		
	queue_free()
