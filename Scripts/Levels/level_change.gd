extends Area3D

@export var next_level: PackedScene
var has_changed: bool = false


func _ready() -> void:
	body_entered.connect(_on_area_body_entered)


func _on_area_body_entered(body) -> void:
	if body.is_in_group("player") and not has_changed:
		SceneManager.load_scene(next_level)
		has_changed = true
		
