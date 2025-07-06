extends CharacterBody2D


const SPEED = 5000.0

@onready var hitbox = $Area2D

func _ready():
	$HeadSprite.play("default")
	$BodySprite.play("idle")


func _physics_process(delta):
	if Dialogic.current_timeline != null:
		return
	#print(Dialogic.current_timeline)
	if Input.is_action_just_pressed("ui_accept") and hitbox.has_overlapping_areas():
		hitbox.get_overlapping_areas()[0].start_dialogue()
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		$BodySprite.play("walk")
		velocity.x = direction * SPEED  * delta
		var flip = (velocity.x < 0)
		if flip:
			$BodySprite.scale.x = -1
			$HeadSprite.scale.x = -1
		else:
			$BodySprite.scale.x = 1
			$HeadSprite.scale.x = 1
	else:
		$BodySprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
