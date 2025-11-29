class_name RoomGeneration
extends Node

@export var map_size : int = 7
@export var rooms_to_gen : int = 12
var room_count: int = 0
var map : Array[bool]
var rooms : Array[Room]
var room_pos_offset : float = 800

var first_room_x : int = 3
var first_room_y : int = 3
var first_room : Room


@export var first_room_scene : PackedScene
@export var room_scenes : Array[PackedScene]
@export var boss_room : PackedScene
@export var player : CharacterBody2D

func _ready() -> void:
	generate()


func generate():
	room_count = 0
	map.resize(map_size * map_size)
	
	check_room(first_room_x, first_room_y, Vector2.ZERO, true)
	instantiate_rooms()


func check_room(x : int, y : int, desired_direction : Vector2, is_first_room : bool = false):
	if room_count >= rooms_to_gen:
		return
	if x < 0 or x > map_size - 1 or y < 0 or y > map_size - 1:
		return
	if get_map(x, y) == true:
		return
	
	room_count += 1
	set_map(x, y, true)
	
	var go_north : bool = randf() > (0.2 if desired_direction == Vector2.UP else 0.8)
	var go_south : bool = randf() > (0.2 if desired_direction == Vector2.DOWN else 0.8)
	var go_east : bool = randf() > (0.2 if desired_direction == Vector2.RIGHT else 0.8)
	var go_west : bool = randf() > (0.2 if desired_direction == Vector2.LEFT else 0.8)
	
	if go_north or is_first_room:
		check_room(x, y - 1, Vector2.UP if is_first_room else desired_direction)
	if go_south or is_first_room:
		check_room(x, y + 1, Vector2.DOWN if is_first_room else desired_direction)
	if go_east or is_first_room:
		check_room(x + 1, y, Vector2.RIGHT if is_first_room else desired_direction)
	if go_west or is_first_room:
		check_room(x - 1, y, Vector2.LEFT if is_first_room else desired_direction)


func instantiate_rooms():
	var boss_room_pos : Vector2 = make_boss_room()
	
	#instansiate room at its designated position
	for x in range(map_size):
		for y in range(map_size):
			if get_map(x,y) == false:
				continue
			
			var room : Room 
			var is_first_room : bool = first_room_x == x and first_room_y == y
			
			#makes 1st room the template else random room from array
			if is_first_room:
				room = first_room_scene.instantiate()
			elif x == boss_room_pos.x and y == boss_room_pos.y:
				room = boss_room.instantiate()
			else:
				room = room_scenes[randi_range(0,len(room_scenes) - 1)].instantiate()
			
			get_tree().root.get_node("/root/Main").add_child.call_deferred(room)
			rooms.append(room)
			
			room.global_position = Vector2(x, y) * room_pos_offset
			
			if is_first_room:
				first_room = room
				
			room.initialize()
	
	# Check for neighbor rooms
	for room in rooms:
		var map_pos : Vector2 = get_map_index(room)
		# Seperate x and y pos
		var x = map_pos.x
		var y = map_pos.y
		
		if y > 0 and get_map(x, y - 1):
			room.set_neighbor.call_deferred(Room.Direction.NORTH, get_room_from_map(x, y - 1))
		if y < map_size - 1 and get_map(x, y + 1):
			room.set_neighbor.call_deferred(Room.Direction.SOUTH, get_room_from_map(x, y + 1))
		if x < map_size - 1 and get_map(x + 1, y):
			room.set_neighbor.call_deferred(Room.Direction.EAST, get_room_from_map(x + 1, y))
		if x > 0 and get_map(x - 1, y):
			room.set_neighbor.call_deferred(Room.Direction.WEST, get_room_from_map(x - 1, y))
	first_room.player_enter.call_deferred(Room.Direction.NORTH, player, true)


func make_boss_room() -> Vector2:
	var farthest_pos : Vector2 = Vector2.ZERO
	var max_distance : float = -1.0
	
	for x in range(map_size):
		for y in range(map_size):
			if get_map(x, y) == false:
				continue
			
			var distance = (Vector2(x, y) - Vector2(first_room_x, first_room_y)).length()
			
			if distance > max_distance:
				max_distance = distance
				farthest_pos = Vector2(x, y)
	
	return farthest_pos


func get_room_from_map (x : int, y : int) -> Room:
	for room in rooms:
		var pos = get_map_index(room)
		
		if pos.x != x or pos.y != y:
			continue
		
		return room
	return null


# Changes vector2 from a float to an int
func get_map_index(room : Room) -> Vector2i:
	return Vector2i(room.global_position / room_pos_offset)


func get_map(x : int, y : int) -> bool:
	# Gets value from 2d array
	return map[x + y * map_size]


func set_map(x : int, y : int, value : bool):
	# Set value to 2d array
	map[x + y * map_size] = value
	
