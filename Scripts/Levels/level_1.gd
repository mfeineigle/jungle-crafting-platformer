extends Level


func _on_player_taken(player: Player) -> void:
	if not has_node("parachute"):
		push_error("Level 1 missing parachute node")
		return
		
	var parachute: Node3D = $parachute
	player.parachute_system.enter_parachute(parachute)
