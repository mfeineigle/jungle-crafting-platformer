extends Control

@onready var toggle_button: Button = $VBoxContainer/Label/Button
@onready var water: Node3D = $"../background/Water"

func _ready() -> void:
	water.hide()
	toggle_button.toggle_mode = true
	toggle_button.toggled.connect(_on_button_toggled)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		water.show()
	else:
		water.hide()
