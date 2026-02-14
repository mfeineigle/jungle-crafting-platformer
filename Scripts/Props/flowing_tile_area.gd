extends Area3D
@onready var water: Node3D = $"../.."


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print(body, " entered the liquid")
		body.enter_water(water.get_flow_dir(), water.flow_speed)

func _on_body_exited(body):
	if body.is_in_group("player"):
		print(body, " left the liquid")
		body.exit_water()
