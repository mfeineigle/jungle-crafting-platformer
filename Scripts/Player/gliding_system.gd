extends Node3D

@onready var player: Player = $".."
@onready var camera: Camera3D = $"../CameraSystem/VerticalSpringArm/HorizontalSpringArm/Camera3D"

# State.GLIDING
@onready var glider_mount: Node3D = $GliderMount
@onready var glider_pivot: Node3D = $GliderPivot
const GLIDE_VERTICAL_SPEED := 6.0
const GLIDE_VERTICAL_ACCEL := 12.0
const GLIDE_GRAVITY := -2.0 # units/sec (tune this)
const GLIDE_BASE_SPEED := 2.0
const GLIDE_BOOST_SPEED := 10.0
const GLIDE_BRAKE_SPEED := 1.0
const GLIDE_ACCEL := 8.0
var current_glider_speed := GLIDE_BASE_SPEED
var target_glider_speed := GLIDE_BASE_SPEED
var glide_tilt_deg_DEFAULT := -25.0
var glide_tilt_deg_BOOST := -40.0
var glide_tilt_deg_BRAKE := -10.0
@onready var target_glider_tilt: float = 0.0
var glider_tilt_tween: Tween
var tilt_in_speed := 0.3
var tilt_out_speed := 0.075
var glider: Node3D = null
var in_updraft: bool = false
var updraft_strength: float = 15.0


func _ready() -> void:
	Signals.enter_glider.connect(_enter_glider)

# State.GLIDING
func _enter_glider() -> void:
	player.set_state(player.State.GLIDING)
	player.velocity = Vector3.ZERO
	# Reparent to mount
	glider.get_parent().remove_child(glider)
	glider_mount.add_child(glider)
	# Snap cleanly to mount
	glider.transform = Transform3D.IDENTITY
	glider.global_position.y += 1
	
func exit_glider() -> void:
	if not glider:
		return
	player.set_state(player.State.NORMAL)
	# Preserve world transform
	var xform := glider.global_transform
	# Detach
	glider_mount.remove_child(glider)
	get_tree().current_scene.add_child(glider)
	# Restore world transform
	glider.global_transform = xform
	glider.global_position.y -= 1.8
	glider = null
	update_glider_tilt()
	
func handle_gliding_movement(delta) -> void:
	# speed
	var boosting := Input.is_action_pressed("up")
	var braking := Input.is_action_pressed("down")
	target_glider_speed = GLIDE_BASE_SPEED
	if boosting:
		target_glider_speed = GLIDE_BOOST_SPEED
	elif braking:
		target_glider_speed = GLIDE_BRAKE_SPEED
	current_glider_speed = lerp(
		current_glider_speed,
		target_glider_speed,
		GLIDE_ACCEL * delta
	)
	# flatten forward to XZ plane (ignore pitch)
	var cam_basis := camera.global_transform.basis
	var forward := -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var target_velocity = forward * current_glider_speed
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, GLIDE_ACCEL * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, GLIDE_ACCEL * delta)
	# vertical position
	var vertical_input: float = 0.0
	if Input.is_action_pressed("jump"):
		vertical_input += 1.0
	if Input.is_action_pressed("descend"):
		vertical_input -= 1.0
	# gravity
	var target_vy := GLIDE_GRAVITY + vertical_input * GLIDE_VERTICAL_SPEED
	player.velocity.y = move_toward(player.velocity.y, target_vy, GLIDE_VERTICAL_ACCEL * delta)
	# updraft
	if in_updraft:
		player.velocity.y += updraft_strength * delta

func update_glider_tilt() -> void:
	# tilt
	target_glider_tilt = 0.0
	if player.state == player.State.GLIDING:
		match target_glider_speed:
			GLIDE_BOOST_SPEED:
				target_glider_tilt = 0.0 if player.is_on_floor() else deg_to_rad(glide_tilt_deg_BOOST)
			GLIDE_BRAKE_SPEED:
				target_glider_tilt = 0.0 if player.is_on_floor() else deg_to_rad(glide_tilt_deg_BRAKE)
			GLIDE_BASE_SPEED:
				target_glider_tilt = 0.0 if player.is_on_floor() else deg_to_rad(glide_tilt_deg_DEFAULT)
			_:
				target_glider_tilt = 0.0
	if glider_tilt_tween:
		glider_tilt_tween.kill()
	glider_tilt_tween = get_tree().create_tween()
	if target_glider_tilt == 0.0:
		glider_tilt_tween.tween_property(
			glider_pivot,
			"rotation:x",
			target_glider_tilt,
			tilt_out_speed
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		glider_tilt_tween.tween_property(
			glider_pivot,
			"rotation:x",
			target_glider_tilt,
			tilt_in_speed
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
