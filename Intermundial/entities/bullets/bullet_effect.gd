class_name BulletEffect
extends Node

func effect(caller:Node3D, bullet:SpecialBullet) -> void:
	push_error("Error in [" + Collections.get_bullet_type(bullet.bullet_type) + "] BulletEffect unconfigured")
