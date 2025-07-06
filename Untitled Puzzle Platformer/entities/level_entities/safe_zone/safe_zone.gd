class_name SafeZone
extends Area2D

signal enter_checkpoint(plane_type: Enums.PlaneTypes, safe_zone_ref: SafeZone)
signal leave_checkpoint()

@export var plane_type: Enums.PlaneTypes = Enums.PlaneTypes.NONE

func _on_area_entered(area):
	if area.get_owner().is_in_group("Player"):
		area.get_owner().heal() #TODO remove this after connecting all safe zone entered signals into the player script
		enter_checkpoint.emit(plane_type, self)
		#area.get_parent().enter_checkpoint(planeType)


func _on_area_exited(area):
	if area.get_owner().is_in_group("Player"):
		leave_checkpoint.emit()
		#area.get_parent().leave_checkpoint()
