extends Area3D
@onready var lava: Node3D = $"../.."


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and  not body.is_dead:
		Signals.player_died.emit()
