extends Node3D

@onready var player: Player = $".."

# State.PARACHUTE
@onready var g_parachute
@onready var parachute_anchor_x: float
@onready var parachute_anchor_y: float
var swing_limit := 1.0
var swing_hits := 0
var last_edge := 0 # -1 = left, 1 = right
var swing_height := 0.5 # max Y offset up/down
var swing_speed := 5.0
var swing_velocity := 0.0
var swing_accel := 10.0 # how fast player input accelerates swing
var swing_damp := 1.0 # slows swing naturally


# State.PARACHUTE
func handle_parachute_movement(delta):
	if Input.is_action_just_pressed("down"):
		exit_parachute()
	var input_dir := Input.get_axis("right", "left")
	player.velocity.x = lerp(player.velocity.x, input_dir * player.SPEED, delta * 5.0)
	player.velocity.y = 0
	player.velocity.z = 0
	var offset = player.global_position.x - parachute_anchor_x
	var t = offset / swing_limit # -1..1
	player.global_position.y = parachute_anchor_y + swing_height * (1 + t*t) # peak in center = low, edges = high
	if abs(offset) >= swing_limit:
		var edge: int = int(sign(offset))
		player.global_position.x = parachute_anchor_x + edge * swing_limit
		# Count only when switching sides
		if edge != 0 and edge != last_edge:
			swing_hits += 1
			last_edge = edge
			if swing_hits >= 3:
				exit_parachute()	

func enter_parachute(parachute):
	g_parachute = parachute
	parachute.get_parent().remove_child(parachute)
	player.add_child(parachute)
	parachute.global_position = player.global_position
	parachute.global_position.y += 11.8
	parachute.global_position.z += 1
	parachute.rotation_degrees.y = 180
	parachute_anchor_x = player.global_position.x
	parachute_anchor_y = player.global_position.y
	player.set_state(player.State.PARACHUTE)
	swing_hits = 0
	last_edge = 0

func exit_parachute():
	# Preserve world transform BEFORE reparenting
	var xform = g_parachute.global_transform
	# Reparent
	player.remove_child(g_parachute)
	player.get_parent().add_child(g_parachute)
	# Restore world transform AFTER reparenting
	g_parachute.global_transform = xform
	player.set_state(player.State.NORMAL)
