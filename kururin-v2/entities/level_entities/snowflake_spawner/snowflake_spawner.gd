class_name SnowflakeSpawner
extends Node2D

@export var snowflake_freeze_duration: float = 1.0
@export var respawn_duration: float = 1.0
@export var snowflake_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	%Snowflake.freeze_duration = snowflake_freeze_duration
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_snowflake():
	var snowflake: Snowflake = snowflake_scene.instantiate()
	add_child(snowflake)
	snowflake.freeze_duration = snowflake_freeze_duration
	snowflake.snowflake_collected.connect(_on_snowflake_snowflake_collected)
	snowflake.name = "Snowflake"

func _on_respawn_timer_timeout():
	_spawn_snowflake()


func _on_snowflake_snowflake_collected():
	%RespawnTimer.start(respawn_duration)
