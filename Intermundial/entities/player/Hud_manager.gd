extends Control


## set needle angle
@export var min_angle: float = 0.0
@export var max_angle: float = 160.0
## needle twitch amount
@export var twitch_amount: float = 10.0

## yeehaw stuff
var yeehaw_meter: float = 0.0 : set = _set_yeehaw_meter
var yeehaw_charged: bool = false

## headbob stuff
var max_drop : float = 5
var initial_pos

@onready var whiskey_controller: Node2D = $WhiskeyControl/whiskeyController
@onready var needle_control: Node2D = %NeedleControl
@onready var player: Player = $"../.."

func _ready() -> void:
	initial_pos = position
	
	update_needle()
	
	## for testing
	await get_tree().create_timer(1.0).timeout
	_set_yeehaw_meter(100.0)


func _process(delta: float) -> void:
	update_needle()
	max_drop += delta * player.velocity.length() * float(player.is_on_floor())
	var bob_offset = drop_effect(max_drop)
	position = bob_offset


# headbob for hud
func drop_effect(time):
	var pos = initial_pos
	pos.y = sin(time * 1) * 3
	pos.x = cos(time * 1 / 2) * 3 * 0.5
	return pos


# yeehaw meter
func _set_yeehaw_meter(value: float) -> void:
	# Clamp the value between 0-100
	yeehaw_meter = clamp(value, 0.0, 100.0)
	update_needle()
	
	if yeehaw_meter >= 100.0 and not yeehaw_charged:
		yeehaw_charged = true


func update_needle() -> void:
	var base_angle = lerp(min_angle, max_angle, yeehaw_meter / 100.0)
	var twitch = randf_range(-twitch_amount, twitch_amount)
	var target_angle = base_angle + twitch
	var tween = create_tween()
	
	tween.tween_property(needle_control, "rotation_degrees", target_angle, 0.5)
