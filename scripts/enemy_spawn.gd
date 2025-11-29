class_name Spawner
extends Node2D

@export var enemy_waves : int = 3 # Number of waves to spawn
@export var enemy_scenes : Array[PackedScene]
@export var boss_scene : Array[PackedScene]

@onready var wave_countdown: Timer = $WaveCountdown

var cur_wave : int = 1

var room : Room
var is_active : bool = false
var spawn_area = Rect2(Vector2(-100,-100), Vector2(200, 200)) # Area for enemies to spawn



func _ready() -> void:
	GlobalSignals.OnPlayerEnterRoom.connect(on_player_enter_room)


#func _draw() -> void:
	#draw_rect(spawn_area, Color(1, 0, 0, 1.0))


func initialize(in_room : Room):
	is_active = false
	room = in_room


func spawn_waves():
	var spawned_enemies = []
	
	for i in len(enemy_scenes):
		var enemy_position = get_random_position()
		
		while is_position_occupied(enemy_position, spawned_enemies):
			enemy_position = get_random_position()
		
		# Spawns enemies
		var enemy = enemy_scenes[i].instantiate()
		enemy.position = enemy_position
		enemy.is_active = true
		get_parent().add_child(enemy)
		spawned_enemies.append(enemy)


func spawn_boss():
	var boss = boss_scene[0].instantiate()
	boss.position = get_random_position()
	boss.is_active = true
	get_parent().add_child(boss)



func _on_wave_countdown_timeout() -> void:
	if enemy_waves > 0 and is_active:
		
		GlobalSignals.DisplayText.emit("Summoning Demons... Wave " + str(cur_wave))
		await get_tree().create_timer(5).timeout
		spawn_waves()
		
		cur_wave += 1
		enemy_waves -= 1
	elif boss_scene and enemy_waves == 0:
		enemy_waves -= 1
		GlobalSignals.DisplayText.emit("HAIL SATAN!")
		spawn_boss()


func on_player_enter_room(player_room : Room):
	is_active = player_room == room


func get_random_position() -> Vector2:
	var x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
	var y = randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	return Vector2(x, y)


func is_position_occupied(pos: Vector2, characters: Array) -> bool:
	for character in characters:
		var character_rect = Rect2(character.position, character.get_node("CollisionShape2D").shape.get_rect().size)
		if character_rect.has_point(pos):
			return true
	return false
