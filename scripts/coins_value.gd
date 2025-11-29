extends Label

func _init() -> void:
	GlobalSignals.OnPlayerUpdateCoin.connect(update_coins)


func _ready() -> void:
	text = "0"


func update_coins(value : int):
	text = str(value)
