class_name HurtboxComponent
extends Area3D

@export var health_component: HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func receive_attack(attack: AttackResource):
	if health_component:
		health_component.damage(attack.damage)
