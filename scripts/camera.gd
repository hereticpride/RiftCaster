extends Camera2D


func _ready() -> void:
	GlobalSignals.OnPlayerEnterRoom.connect(on_player_enter_room)


func on_player_enter_room(room : Room):
	global_position = room.global_position
