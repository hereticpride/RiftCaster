class_name RoomEntrance
extends Node2D

@export var direction : Room.Direction = Room.Direction.NORTH

@onready var wall: StaticBody2D = $Wall
@onready var wall_collider: CollisionShape2D = $Wall/CollisionShape2D

@onready var door: Node2D = $Door
@onready var barrier: StaticBody2D = $Door/Barrier
@onready var barrier_collider : CollisionShape2D = $Door/Barrier/CollisionShape2D

@onready var player_spawn: Node2D = $PlayerSpawn
@onready var exit_trigger: Area2D = $Exit

var neighbor : Room

func _ready() -> void:
	exit_trigger.body_entered.connect(_on_body_entered_exit_trigger)
	toggle_wall(true)
	
	for child in get_children():
		if child is Spawner:
			
			child.initialize(self)


func set_neighbor(neighbor_room : Room):
	neighbor = neighbor_room
	toggle_wall(false)


func toggle_wall(toggle : bool):
	wall.visible = toggle
	wall_collider.disabled = !toggle
	
	door.visible = !toggle


func open_door():
	if wall.visible:
		return
	
	barrier.visible = false
	barrier_collider.disabled = true


func close_door():
	if barrier.visible:
		return
	
	barrier.visible = true
	barrier_collider.disabled = false


func _on_body_entered_exit_trigger(body):
	if body.is_in_group("Player"):
		neighbor.player_enter(get_neighbor_entry_direction(), body)


func get_neighbor_entry_direction() -> Room.Direction:
	if direction == Room.Direction.NORTH:
		return Room.Direction.SOUTH
	elif direction == Room.Direction.SOUTH:
		return Room.Direction.NORTH
	elif direction == Room.Direction.EAST:
		return Room.Direction.WEST
	else:
		return Room.Direction.EAST
