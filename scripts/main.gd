extends Node2D

@onready var info_panel: Panel = $CanvasLayer/InfoPanel
@onready var label: Label = $CanvasLayer/InfoPanel/Margins/Label

func _ready() -> void:
	info_panel.visible = false
	GlobalSignals.DisplayText.connect(display_text)


func display_text(input_string : String):
	label.text = input_string
	info_panel.visible = true
	await get_tree().create_timer(5).timeout
	info_panel.visible = false
