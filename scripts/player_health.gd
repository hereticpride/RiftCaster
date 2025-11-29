extends GridContainer

@onready var full_heart : Texture = preload("res://sprites/ui/heart.png")
@onready var empty_heart : Texture = preload("res://sprites/ui/emptyheart.png")

var heart_icons : Array[TextureRect]


func _init() -> void:
	GlobalSignals.OnPlayerUpdateHealth.connect(update_health)


func _ready() -> void:
	for child in get_children():
		if child is TextureRect:
			heart_icons.append(child)


func update_health(cur_hp : int, max_hp : int):
	for i in len(heart_icons):
		if i >= max_hp:
			heart_icons[i].visible = false
			continue
		
		heart_icons[i].visible = true
		
		if i < cur_hp:
			heart_icons[i].texture = full_heart
		else:
			heart_icons[i].texture = empty_heart
