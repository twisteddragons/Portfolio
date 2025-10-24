extends Node3D


@export_category("Level Generation Settings")
@export var num_rooms: int = 10

@export_category("Room References")
@export var start_room: PackedScene
@export var end_room: PackedScene
@export var room_scenes: Array[PackedScene] = []

var room_instances: Array[Node3D] = []


@onready var kill_floor: Node3D = %kill_floor





func _ready():
	generate_level()
	initilize_killfloor()

func generate_level():
	var prev_entrance:Node3D
	for i in range(num_rooms):
		var room: Node3D
		
		if i == 0:
			# First room - use starting room if you have a specific one
			room = start_room.instantiate()
		elif i == num_rooms - 1:
			room = end_room.instantiate()
			
		else:
			# Random room from your collection
			var random_index = randi() % room_scenes.size()
			room = room_scenes[random_index].instantiate()
		
		add_child(room)
		room_instances.append(room)
		
		 #Spawn enemies in second room
		if i == 1:
			room.spawn_enemies()
		# Skip room zero
		if i > 1:
			prev_entrance.find_child("Area3D").body_entered.connect(Callable(room, "on_room_entered"))
		# first room at origin
		if i == 0:
			room.position = Vector3.ZERO  
		else:
			#using get_node not sure if thats the best aproach
			var prev_room = room_instances[i-1]
			var exit_marker = prev_room.get_node("Exit")
			var entrance_marker = room.get_node("Entrance")
			
			var entrance_offset = room.position - entrance_marker.global_position
			
			# snaps next room enterance to exit
			room.position = exit_marker.global_position + entrance_offset
			
			#room.rotation = exit_marker.global_rotation
			# Save previous entrance for next room's spawn_enemies
			prev_entrance = entrance_marker
		room.initilize()
	



func initilize_killfloor():
	RespawnManager.kill_floor_distance = kill_floor.global_position.y
