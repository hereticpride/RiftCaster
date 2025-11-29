extends CharacterBody2D

@export_category("Player Stats")
@export var max_hp: int = 5
@export var cur_hp: int = 5
@export var move_speed : int = 100
@export var fire_rate: float = 0.5
@export var damage: float = 1
@export var coins : int = 0
var cooldown : float

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var weapon: Node2D = $Weapon
@onready var muzzle: Node2D = $Weapon/Muzzle


var sound_wave : PackedScene = preload("res://scenes/sound_wave.tscn")


func _ready() -> void:
	GlobalSignals.OnPlayerUpdateHealth.emit.call_deferred(cur_hp, max_hp)


func _physics_process(_delta: float) -> void:
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_input * move_speed
	move_and_slide()


func _process(_delta: float) -> void:
	# Gets the mouse position and rotates weapon
	var mouse_pos: Vector2 = get_global_mouse_position()
	var mouse_dir: Vector2 = (mouse_pos - global_position).normalized()
	weapon.rotation_degrees = rad_to_deg(mouse_dir.angle()) + 90
	
	player_sprite.flip_h = mouse_dir.x < 0
	
	if Input.is_action_pressed("shoot"):
		if Time.get_unix_time_from_system() - cooldown > fire_rate:
			shoot()


func shoot():
	cooldown = Time.get_unix_time_from_system()
	
	var proj = sound_wave.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = muzzle.global_position
	proj.rotation = weapon.rotation
	proj.shooter = self
	$Strum.play()


func take_damage(amount : int):
	cur_hp -= amount
	
	damage_flash()
	$Oof.play()
	
	GlobalSignals.OnPlayerUpdateHealth.emit(cur_hp, max_hp)
	
	if cur_hp <= 0:
		die()


func damage_flash():
	visible = false
	await get_tree().create_timer(0.07).timeout
	visible = true


func heal(amount : int):
	cur_hp += amount
	
	GlobalSignals.OnPlayerUpdateHealth.emit(cur_hp, max_hp)


func is_full_health() -> bool:
	if cur_hp == max_hp:
		return true
	return false

func die():
	GlobalSignals.DisplayText.emit("Sold your soul for rock and roll, now you pay the devil's toll")
	get_tree().paused = true
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func gain_coins(amount : int):
	coins += amount
	
	GlobalSignals.OnPlayerUpdateCoin.emit(coins)


func lose_coins(amount : int):
	coins -= amount
	
	GlobalSignals.OnPlayerUpdateCoin.emit(coins)
