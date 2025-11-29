extends Area2D

enum ItemType 
{
	COIN,
	HEALTH,
	DAMAGE,
	SPEED,
	FIRE_RATE
}

@export var type : ItemType
@export var item_name : String
@export var value : float
@export_multiline var item_description : String
@export var is_paid_item : bool = false
@export var cost : int = 0

func _ready() -> void:
	$Panel.visible = false
	if is_paid_item:
		cost = randi_range(2, 5)
		$Panel.visible = true
		$Panel/ItemPrice.text = str(cost)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	
	if not is_paid_item or body.coins >= cost:
		body.lose_coins(cost)
		
		if type == ItemType.HEALTH:
			if body.is_full_health():
				return
			body.heal(int(value))
		elif type == ItemType.COIN:
			body.gain_coins(int(value))
			GlobalSignals.DisplayText.emit(str(item_name) + ": " + str(item_description))
		elif type == ItemType.FIRE_RATE:
			body.fire_rate -= value
			GlobalSignals.DisplayText.emit(str(item_name) + ": " + str(item_description))
		elif type == ItemType.SPEED:
			body.move_speed += value
			GlobalSignals.DisplayText.emit(str(item_name) + ": " + str(item_description))
		elif type == ItemType.DAMAGE:
			body.damage += value
			GlobalSignals.DisplayText.emit(str(item_name) + ": " + str(item_description))
		
		body.get_node("Chug").play()
		queue_free()
	else:
		$Panel/ItemPrice.text = "[color=red]" + str(cost)
		GlobalSignals.DisplayText.emit("Not enough coins")
	
