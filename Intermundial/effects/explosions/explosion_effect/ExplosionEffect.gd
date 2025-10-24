@tool
extends Node3D

signal explosion_emission_finished

@onready var smoke: GPUParticles3D = $smoke
@onready var trails: GPUParticles3D = $trails
@onready var explosion: GPUParticles3D = $explosion
@onready var boom: AudioStreamPlayer3D = $BOOM

@export_tool_button("Demo Explosion") var e = explode

const TOTAL_NUM_EMITTERS:int = 3
var num_emitters:int = 0

func _ready() -> void:
	smoke.finished.connect(on_emitter_finished)
	trails.finished.connect(on_emitter_finished)
	explosion.finished.connect(on_emitter_finished)
	num_emitters = TOTAL_NUM_EMITTERS

func explode():
	smoke.emitting = true
	trails.emitting = true
	explosion.emitting = true
	boom.play()

func on_emitter_finished() -> void:
	num_emitters += 1
	if num_emitters == TOTAL_NUM_EMITTERS:
		emit_signal("explosion_emission_finished")
