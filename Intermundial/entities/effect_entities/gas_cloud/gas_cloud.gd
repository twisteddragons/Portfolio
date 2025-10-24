extends Node3D

const GAS_DAMAGE:int = 1
const LIFE_DURATION:float = 6.0
const DISAPPEAR_WEIGHT:float = 0.05
const GROW_RATE:float = 0.03
const MAX_SCALE:float = 1.25
const OVERSCALE_RATE:float = 0.03

@onready var life_timer:Timer = $Timer

var gas_scale: float = 0.0
var scale_rate: float = 0.25
var target_scale: float = 1.0
var cur_disappear_weight: float = 0.0

func _ready() -> void:
	scale = Vector3(0.0,0.0,0.0)
	life_timer.timeout.connect(begin_disappearing)
	life_timer.start(LIFE_DURATION)

func _process(delta: float) -> void:
	gas_scale = lerp(gas_scale, target_scale, scale_rate)
	scale = Vector3(gas_scale, gas_scale, gas_scale)
	target_scale += GROW_RATE*delta
	%MeshInstance3D.transparency = lerp(%MeshInstance3D.transparency, 1.0, cur_disappear_weight)
	if %MeshInstance3D.transparency >= 0.95: queue_free()
	for c in %Area3D.get_overlapping_bodies():
		if c.is_in_group(Collections.GLOBAL_GROUPS.DAMAGEABLE):
			c.take_damage(GAS_DAMAGE)

func begin_disappearing() -> void:
	cur_disappear_weight = DISAPPEAR_WEIGHT
	target_scale = MAX_SCALE
	scale_rate = OVERSCALE_RATE
