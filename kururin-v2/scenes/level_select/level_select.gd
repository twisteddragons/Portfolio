extends Node2D

func _process(delta):
	var focused_node: Control = get_viewport().gui_get_focus_owner()
	if focused_node != null:
		if focused_node.is_in_group("LevelSelectButton"):
			%MiniPlane.global_position = %MiniPlane.global_position.move_toward(focused_node.global_position + focused_node.pivot_offset, 1)
			#var p: Vector2 = $MiniPlane.global_position
			#var q: Vector2 = focused_node.global_position
			#q += focused_node.size/2
			#var pq: Vector2 = q - p
			#if pq.length() > 1:
				#pq = pq.normalized()
				#$MiniPlane.translate(pq)
			#else:
				#$MiniPlane.global_position = q

func receive_data(data):
	## if the level was completed,
	if data != null:
		if data.level_completed != null: ##TODO: change from bool to vector2i or 3i to avoid looping through all levels
			if data.level_completed:
				## update stats for completed level
				for level_select_button: LevelSelectButton in get_tree().get_nodes_in_group("LevelSelectButton"):
					level_select_button.update_stats()
					#await level_select_button.stat_update_finished
				
				## unlock the next level(s)
				for level_select_button: LevelSelectButton in get_tree().get_nodes_in_group("LevelSelectButton"):
					level_select_button.unlock()
					#await level_select_button.unlock_finished

func _on_garage_button_pressed():
	%Garage.translate(Vector2(0,0), Tween.EASE_OUT)
	#var tween = get_tree().create_tween()
	#tween.tween_property(%Garage, "position", Vector2(0,0), %Garage.leave_duration)
