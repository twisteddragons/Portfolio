## contains simple functions that are useful in many places and honestly should be part of godot already
extends Node

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

## custom float rounding cause stinky godot doesnt have one
## NUM: number to round
## DIGIT: decimal place to round to
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

## Takes an image uid or path and returns polygons 
## similar to the method godot uses to convert sprite into polygons within the editor
## expand pixels can be negative to shrink instead
func image_to_polygons(image_uid: String, expand_pixels: int = 0) -> Array[PackedVector2Array]:
	# Load image
	var image = Image.new()
	image.load(image_uid)
	
	# convert image to bitmap
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	
	# convert bitmap to polygon
	var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2(Vector2(0,0), bitmap.get_size()))
	
	
	# expand away from (0,0) by number of pixels
	for i in polygons.size():
		var polygon = polygons[i]
		for j in polygon.size():
			## center, NOTE: maybe make this an param later
			polygon[j] -= Vector2(bitmap.get_size()/2)
			var point = polygon[j]
			var x_multiplier = 1 if point.x > 0 else -1
			var y_multiplier = 1 if point.y > 0 else -1
			point.x = point.x + (expand_pixels * x_multiplier)
			point.y = point.y + (expand_pixels * y_multiplier)
			polygon[j] = point
		polygons[i] = polygon
	
	return polygons

func tessalate_line_even_length(line2d: Line2D, max_stages: int = 5, tolerance_length: float = 20.0) -> Line2D:
	var curve = Curve2D.new()
	
	for point in line2d.points:
		curve.add_point(point)
	
	var tessalated_points: PackedVector2Array = curve.tessellate_even_length(max_stages, tolerance_length)# polygons[0]
	
	var new_line2d = Line2D.new()
	new_line2d.points = tessalated_points
	return new_line2d
