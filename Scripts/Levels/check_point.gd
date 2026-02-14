class_name Checkpoint
extends Node3D

@onready var animation_player: AnimationPlayer = $active_orb/AnimationPlayer
@onready var active_orb: MeshInstance3D = $active_orb
@onready var area: Area3D = $Area3D

## The current level
@export var level: Node3D

var is_cur_checkpoint: bool = false

func _ready() -> void:
	add_to_group("checkpoints")
	area.body_entered.connect(_on_body_entered)
	active_orb.visible = false


func _on_body_entered(body) -> void:
	if body.is_in_group("player"):# and is_cur_checkpoint == false:
		level.cur_check_point = self
		# turn off all checkpoints
		get_tree().call_group("checkpoints", "set_active_orb", false)
		# turn this checkpoint back on
		active_orb.visible = true
		animation_player.play("active")

func set_active_orb(active: bool) -> void:
	active_orb.visible = active
	animation_player.stop()
