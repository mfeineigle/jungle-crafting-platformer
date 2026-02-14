extends Node3D
@onready var player: Player = $".."

#  State.CLIMBING
const climb_speed: float = 4.0
var climb_max_y: float
var climb_min_y: float

func _ready() -> void:
	pass # Replace with function body.


# State.CLIMBING
func enter_rope(rope):
	player.set_state(player.State.CLIMBING)
	player.velocity = Vector3.ZERO
	# Snap player to rope
	player.global_transform.origin = rope.enter_marker.global_transform.origin
	climb_max_y = rope.get_parent().global_position.y + 1
	climb_min_y = rope.get_parent().global_position.y - rope.get_parent().current_height + 1.5

func exit_rope(rope):
	player.global_transform.origin = rope.exit_marker.global_transform.origin
	player.set_state(player.State.NORMAL)
	
func enter_ladder(ladder):
	player.set_state(player.State.CLIMBING)
	player.velocity = Vector3.ZERO
	# Snap player to ladder
	player.global_transform.origin = ladder.enter_marker.global_transform.origin
	climb_max_y = ladder.get_parent().global_position.y + ladder.get_parent().current_height
	climb_min_y = ladder.get_parent().global_position.y + 1
	
func exit_ladder(ladder):
	# Snap player to ladder's center
	player.global_transform.origin = ladder.exit_marker.global_transform.origin
	player.set_state(player.State.NORMAL)
	
func handle_climb_movement(delta):
	var vertical := Input.get_action_strength("up") - Input.get_action_strength("down")
	if vertical == 0:
		return
	var new_y: float = player.global_position.y + vertical * climb_speed * delta
	player.global_position.y = clamp(new_y, climb_min_y, climb_max_y)
