extends RigidBody3D

@onready var area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var fall_delay: float = 0.25

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		animation_player.play("rumble")
		await get_tree().create_timer(fall_delay).timeout
		freeze = false
		sleeping = false
		await get_tree().create_timer(fall_delay).timeout
		animation_player.stop()
