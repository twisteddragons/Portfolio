extends Control

const HEALTH_SUFFIX: String = "_health"
@onready var health_sprite: AnimatedSprite2D = %Health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_health(health: int = 3):
	health = clamp(health, 0, 3) #TODO: magic number 3, max health could be different depending on level
	health_sprite.play(str(health) + HEALTH_SUFFIX)

func update_eggs(egg_id: int):
	$EggsAnimationPlayer.queue("egg_" + str(egg_id + 1) + "_collected")
	
	
func _on_player_health_changed(new_value: int):
	update_health(new_value)
	

func _on_egg_collected(egg_id: int):
	update_eggs(egg_id)


func _on_player_took_damage():
	$FeatherAnimationPlayer.queue("feather_disappear")
