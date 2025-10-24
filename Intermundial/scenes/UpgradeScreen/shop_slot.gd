extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var price_tag: Label = $TextureRect/PriceTag


#floating effect
@export var float_strength: float = 8.0
@export var float_duration: float = 5.0

#price
@export var price : int = 1

#refrences
var bullet_data : SpecialBullet
var shop_screen : ShopScreen

#more floating effect stuff
var original_position: Vector2
var original_rotation: float
var current_tween: Tween


func _ready() -> void:
	original_position = texture_rect.position
	original_rotation = texture_rect.rotation_degrees
	
	start_random_float()
	update_display()

func update_display():
	if bullet_data:
		texture_rect.texture = bullet_data.side_sprite
		price_tag.text = str(price)
	else:
		print("failed")
	

func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("Right_click"):
		if shop_screen.money >= price :
			shop_screen.money -= price
			shop_screen.update_money()
			var data = bullet_data
			shop_screen.add_bullet_to_res(data)
			print("bought")
			queue_free()



func start_random_float():
	current_tween = create_tween()
	current_tween.set_loops()
	
	# Generate random target position within a circle
	var random_angle = randf() * TAU
	var random_distance = randf() * float_strength
	var target_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	
	# Create the animation sequence
	current_tween.tween_method(_apply_float_position, Vector2.ZERO, target_offset, float_duration / 2)
	current_tween.tween_method(_apply_float_position, target_offset, Vector2.ZERO, float_duration / 2)

func _apply_float_position(offset: Vector2):
	texture_rect.position = original_position + offset
	# Add slight rotation based on horizontal movement
	texture_rect.rotation_degrees = original_rotation + offset.x * 0.5
