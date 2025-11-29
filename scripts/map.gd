extends GridContainer

var room_gen : RoomGeneration

var icons : Array[TextureRect]

var default_texture : Texture = preload("res://sprites/ui/gridempty.png")
var player_room_texture : Texture = preload("res://sprites/ui/gridfill.png")

func _ready() -> void:
	GlobalSignals.OnPlayerEnterRoom.connect(on_player_enter_room)


func on_player_enter_room (room : Room):
	if not room_gen:
		room_gen = get_node("/root/Main/RoomManager")
		
		for child in get_children():
			if child is TextureRect:
				icons.append(child)
	#loop through each element of 2d array
	for x in range(room_gen.map_size):
		for y in range(room_gen.map_size):
			#gets the room itself
			var r = room_gen.get_room_from_map(x, y)
			#get index for icons
			var i = x + y * room_gen.map_size
			
			if i >= len(icons):
				continue
			
			if not r:
				icons[i].texture = null
			elif r == room:
				icons[i].texture = player_room_texture
			else:
				icons[i].texture = default_texture
