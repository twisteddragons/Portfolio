class_name Door
extends AnimatableBody3D

# open
@export var open_offset: Vector3 = Vector3(0, 2, 0)

@export var time : float = 1.5
@export var pause : float = 0.7

var open : bool = false
var _closed_position: Vector3
var _open_position: Vector3

func config() -> void:
	_closed_position = global_position
	_open_position = _closed_position + open_offset
	open_door()

func open_door():
	if !open:
		var move_tween = create_tween()
		move_tween.tween_property(self,"position",_open_position,time)
		open = true


func close_door():
	if open:
		var move_tween = create_tween()
		move_tween.tween_property(self,"position",_closed_position,time)
		open = false
