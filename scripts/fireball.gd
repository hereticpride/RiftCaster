extends Area2D

@export var base_speed: float = 150
var shooter: CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite


func _process(delta: float) -> void:
	#move projectile up on y axis
	translate(-transform.y * base_speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	elif body.has_method("take_damage"):
		body.take_damage(shooter.damage)
	
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
