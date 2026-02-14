extends Node3D

@export var player: CharacterBody3D

@onready var vertical_arm: SpringArm3D = $VerticalSpringArm
@onready var camera: Camera3D = $VerticalSpringArm/HorizontalSpringArm/Camera3D
@onready var gliding_system: Node3D = $"../GlidingSystem"

# ARM
var varm_tween: Tween
var default_varm_x = 0.0
var default_varm_y = -1.0
@export var glider_varm_x: float = 1.0
@export var glider_varm_y: float = -2.0
# FOV
var camera_tween: Tween
var default_fov: float = 75.0
@export var glide_fov: float = 75.0
@export var glide_brake_fov: float = 105.0
@export var glide_boost_fov: float = 60.0
@export var glide_fov_tween_speed: float = 0.5

var camera_rotation: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.001
var max_y_rotation_down: float = 1.0
var max_y_rotation_up: float = 1.0
var input_enabled := true


func _on_crafting_toggled(is_open):
	input_enabled = !is_open

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#mouse_mode(Input.MOUSE_MODE_CAPTURED) #note disabled for level1
	Signals.camera_toggled.connect(_on_crafting_toggled)
	sync_camera()

func sync_camera() -> void:
	camera_rotation.x = -player.rotation.y
	vertical_arm.rotation.x = -camera_rotation.y

func _process(_delta: float) -> void:
	if player.state != player.State.GLIDING:
		set_glide_fov(default_fov)
		set_glide_varm(default_varm_x, default_varm_y)
	else:
		if gliding_system.target_glider_speed == gliding_system.GLIDE_BOOST_SPEED:
			set_glide_fov(glide_boost_fov)
		elif gliding_system.target_glider_speed == gliding_system.GLIDE_BRAKE_SPEED:
			set_glide_fov(glide_brake_fov)
		else:
			set_glide_fov(glide_fov)
		set_glide_varm(glider_varm_x, glider_varm_y)

func set_glide_varm(x: float, y: float):
	if varm_tween:
		varm_tween.kill()
	varm_tween = get_tree().create_tween()
	varm_tween.set_parallel()
	varm_tween.tween_property(vertical_arm, "position", Vector3(x, y, 0.0), glide_fov_tween_speed)
	
func set_glide_fov(fov):
	if camera_tween:
		camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	camera_tween.tween_property(camera, "fov", fov, glide_fov_tween_speed)
	
	
	
func _input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		var mouse_event: Vector2 = event.screen_relative * mouse_sensitivity
		camera_look(mouse_event)

func camera_look(mouse_movement: Vector2) -> void:
	camera_rotation += mouse_movement
	camera_rotation.y = clamp(
		camera_rotation.y,
		-max_y_rotation_up,
		max_y_rotation_down
	)
	# yaw
	player.rotation.y = -camera_rotation.x
	# pitch
	vertical_arm.rotation.x = -camera_rotation.y
