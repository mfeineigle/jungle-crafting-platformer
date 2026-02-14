extends Node3D

@onready var world: Node3D = $World
@onready var ui_root: Control = $UI

func _ready():
	SceneManager.scene_loaded.connect(_on_scene_loaded)


func _on_scene_loaded(scene: Node) -> void:
	if scene.is_in_group("player"):
		world.add_child(scene)
	elif scene.is_in_group("level"):
		world.add_child(scene)
		scene.call_deferred("take_player")  # let level handle positioning
	elif scene.is_in_group("ui"):
		ui_root.add_child(scene)
