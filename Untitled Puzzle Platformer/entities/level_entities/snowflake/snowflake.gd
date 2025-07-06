class_name Snowflake
extends Area2D

signal snowflake_collected()

@export var freeze_duration: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func collected():
	%AnimationPlayer.play("collected")
	snowflake_collected.emit()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.freeze(freeze_duration)
		collected()
		#queue_free()
