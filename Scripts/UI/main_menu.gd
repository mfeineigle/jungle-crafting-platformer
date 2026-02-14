extends Node3D
@onready var camera: Camera3D = $Camera3D
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var player: Player = $"../Player"

# Buttons
@onready var start_button: StaticBody3D = $StartButton
@onready var start_col: CollisionShape3D = $StartButton/StartCol
@onready var start_anim: AnimationPlayer = $StartButton/StartAnim

@onready var quit_button: StaticBody3D = $QuitButton
@onready var quit_mesh: MeshInstance3D = $QuitButton/QuitMesh
@onready var quit_anim: AnimationPlayer = $QuitButton/QuitAnim

@onready var lvl_sel_button: StaticBody3D = $LvlSelButton
@onready var lvl_sel_mesh: MeshInstance3D = $LvlSelButton/LvlSelMesh
@onready var lvl_sel_anim: AnimationPlayer = $LvlSelButton/LvlSelAnim

func _ready() -> void:
	Signals.loaded_level.connect(_loaded_level)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_ray()

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var ray_result = space.intersect_ray(ray_query)
	if ray_result:
		detect_button(ray_result.collider)

func detect_button(collider):
	match collider:
		start_button: # Start new game: activate Player and load Level1
			start_anim.play("button_pressed")
			await start_anim.animation_finished
			var scene: PackedScene = load("res://Levels/Level1.tscn")
			SceneManager.load_scene(scene)
			player.show()
			player.set_process(true)
			player.set_physics_process(true)
			player.camera.current = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			directional_light_3d.queue_free()
			world_environment.queue_free()
			queue_free()
		lvl_sel_button:
			lvl_sel_anim.play("button_pressed")
			await lvl_sel_anim.animation_finished
			Signals.open_lvl_select.emit()
		quit_button:
			quit_anim.play("button_pressed")
			await quit_anim.animation_finished
			get_tree().quit()

func _loaded_level() -> void:
	player.show()
	player.set_process(true)
	player.set_physics_process(true)
	player.camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	directional_light_3d.queue_free()
	world_environment.queue_free()
	queue_free()
