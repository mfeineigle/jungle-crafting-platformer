extends Collectible

@onready var end_marker: Marker3D = $end_marker

func interact_action(player: Player):
	player.is_movement = false
	do_the_swing(player, player.global_position, end_marker.global_position, 2.0, 2.0)

func do_the_swing(player: Player, start_pos: Vector3, end_pos: Vector3, peak_height: float = 5.0, duration: float = 1.0):
	var tween := get_tree().create_tween()

	tween.tween_method(
		Callable(self, "_update_swing").bind(player, start_pos, end_pos, peak_height),
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(Callable(self, "_on_swing_finished").bind(player))

	tween.play()
	
func _update_swing(t: float, player: Player, start_pos: Vector3, end_pos: Vector3, peak_height: float):
	var horizontal = start_pos.lerp(end_pos, t)
	var vertical = start_pos.y + (end_pos.y - start_pos.y) * t - sin(t * PI) * peak_height
	player.global_position = Vector3(horizontal.x, vertical, horizontal.z)
	
func _on_swing_finished(player: Player):
	player.is_movement = true
	
	
