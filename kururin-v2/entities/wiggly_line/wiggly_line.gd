class_name WigglyLine
extends Line2D

@export var noise: Noise
@export var amplitude: float = 1.0
#@export var wavelength: float = 1.0
#@export var speed: float = 1.0
#@export var max_offset: Vector2 = Vector2(5, 5)

@onready var point_origins: PackedVector2Array = points

#TODO: support swapping to new point array 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#var image = Image.new()
	#image.load("res://entities/player/art/wings/base/SMALL_X.png")
	#
	#var bitmap = BitMap.new()
	#bitmap.create_from_image_alpha(image)
	#
	#var polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2(Vector2(0,0), bitmap.get_size()))
	#
	#set_wiggly_points(polygons[0])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if true:
		for i in points.size():
			var j: int = Time.get_ticks_msec()
			#x_noise.get_noise_2d(i * 500, j)
			
			var x: float = noise.get_noise_3d(i * 1000, j, 0) * amplitude
			var y: float = noise.get_noise_3d(i * 1000, j, 1000) * amplitude
			
			set_point_position(i, point_origins[i] + Vector2(x,y))
		
		#var x: float = points[i].x
		#var y: float = points[i].y
		#x += randf()
		#y += randf()
		#x -= randf()
		#y -= randf()
		
		#x += randf() * max_offset.x
		#y += randf() * max_offset.y
		#x -= randf() * max_offset.x
		#y -= randf() * max_offset.y
		

func set_wiggly_points(point_array: PackedVector2Array):
	points = point_array
	point_origins = point_array
