class_name Enemy
extends CharacterBody2D

@export_category("Enemy Stats")
@export var enemy_name: String
@export var current_hp : int = 4
@export var max_hp : int = 4
@export var move_speed : float = 20
@export var damage : int = 1
@export var attack_range : float = 10
@export var attack_rate : float = 0.5
@export var is_boss : bool = false

@export_category("Item Values")
@export var always_has_item : bool
@export var items : Array[PackedScene]

@onready var sprite: AnimatedSprite2D = $EnemySprite

var room : Room
var is_active : bool = false

var player : CharacterBody2D
var player_direction : Vector2
var player_distance : float
var last_attack : float

func _ready() -> void:
	#gets the first node in the Player Group
	player = get_tree().get_first_node_in_group("Player")


func initialize(in_room : Room):
	is_active = false
	room = in_room


func _physics_process(_delta: float) -> void:
	if not is_active or player == null:
		return
	#determines player position and distance
	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	
	sprite.flip_h = player_direction.x < 0
	
	if player_distance < attack_range:
		try_attack()
		return
	
	velocity = player_direction * move_speed
	move_and_slide()


func try_attack():
	#check if the attack cooldown has finished
	if Time.get_unix_time_from_system() - last_attack < attack_rate:
		return
	last_attack = Time.get_unix_time_from_system()
	
	player.take_damage(damage)


func take_damage(amount : int):
	current_hp -= amount
	damage_flash()
	$Urgh.play()
	
	if current_hp <= 0:
		die()


func damage_flash():
	visible = false
	await get_tree().create_timer(0.07).timeout
	visible = true


func die():
	GlobalSignals.OnEnemyDefeat.emit(self)
	if randf() >= 0.7 or always_has_item:
		drop_item()
	if is_boss:
		get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
	
	queue_free()


func drop_item():
	var item = items[randi() % items.size()].instantiate()
	item.is_paid_item = false
	item.cost = 0
	item.global_position = position
	get_parent().add_child.call_deferred(item)
