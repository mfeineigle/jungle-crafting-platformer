extends Area3D

@export var trap: Node3D

var is_tripped: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body.is_in_group("player") and not is_tripped:
		is_tripped = true
		Signals.trap_triggered.emit(trap)
