extends CanvasLayer

@onready var vbox: VBoxContainer = $PanelContainer/VBoxContainer


func _ready() -> void:
	hide()
	Signals.open_lvl_select.connect(_open)
	for i in range(6):
		var btn := vbox.get_node("Button%d" % i) as Button	
		btn.set_meta("level_id", i)
		btn.pressed.connect(_on_load_level_pressed.bind(i))

func _on_load_level_pressed(lvl) -> void:
	var scene: PackedScene = load("res://Levels/Level"+str(lvl)+".tscn")
	SceneManager.load_scene(scene)
	Signals.loaded_level.emit()
	_close()


func _open() -> void:
	show()
	
func _close() -> void:
	hide()
