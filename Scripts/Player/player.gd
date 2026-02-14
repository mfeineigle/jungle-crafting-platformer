extends CharacterBody3D
class_name Player

# Camera
@onready var camera: Camera3D = $CameraSystem/VerticalSpringArm/HorizontalSpringArm/Camera3D
@onready var camera_system: Node3D = $CameraSystem

# States
enum State { NORMAL, CLIMBING, PARACHUTE, GLIDING, BUILDING }
var state: State

# State systems
@onready var parachute_system: Node3D = $ParachuteSystem
@onready var build_system: Node = $BuildSystem
@onready var gliding_system: Node3D = $GlidingSystem
@onready var climbing_system: Node3D = $ClimbingSystem
@onready var animation_system: AnimationSystem = $AnimationSystem

# State.NORMAL
const SPEED: float = 5.0
const RUN_SPEED: float = 10.0
const JUMP_VELOCITY: int = 6
const GRAVITY: float = -10
const FALL_GRAVITY: float = -15
var is_running: bool = false
var is_movement: bool = true

# Jumping
var jump_available: bool = false
var was_on_floor: bool = false
var is_in_air: bool = true
@onready var jump_buffer_timer: Timer = $Timers/JumpBufferTimer
@onready var coyote_timer: Timer = $Timers/CoyoteTimer

# Crouching
@onready var crouch_detect: ShapeCast3D = $CrouchDetect
@onready var uncrouch_timer: Timer = $Timers/UncrouchTimer
var is_crouching: bool = false
var delay_uncrouch: bool = false

# Interacting
@export var hold_time := 0.4
var interact_held := false
var hold_timer := 0.0
var hold_triggered := false

# Crafting
var inventory: Array = []
var inventory_tutorial_found_item: bool = false

# Water
@onready var water_detect_area: Area3D = $WaterDetectArea
const WATER_POLL_INTERVAL: float = 0.1
var water_poll_accum := 0.0
var in_water: bool = false
var water_flow_dir: Vector3 = Vector3.ZERO
var water_flow_speed: float = 0.0
var water_count: int = 0

# Air hazard
var in_wind_hazard: bool = false
var wind_flow_dir: Vector3 = Vector3.ZERO
var wind_flow_speed: float = 0.0
var wind_acceleration = 1500.0

# Ground Indicator
@onready var ground_shadow: Sprite3D = $GroundIndicator/GroundShadow
@onready var ground_ray: RayCast3D = $GroundIndicator/GroundRay


func _ready() -> void:
	if get_tree().get_nodes_in_group("main_menu"):
		set_process(false)
		set_physics_process(false)
	else: # running scene directly
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true
	Signals.craft_remove.connect(_on_craft_remove)
	Signals.craft_add.connect(_on_craft_add)
	Signals.wheel_selection_made.connect(_on_wheel_selection)
	ground_ray.target_position = Vector3.DOWN * 100.0
	inventory.append(load("res://Items/Resources/glider.tres"))
	inventory.append(load("res://Items/Resources/ladder.tres"))
	inventory.append(load("res://Items/Resources/rope.tres"))
	Signals.inventory_changed.emit(inventory)

func _process(delta):
	if interact_held: # interact menu timer
		hold_timer += delta
		if hold_timer >= hold_time and not hold_triggered:
			hold_triggered = true
			_try_interact_action_held()
	if ground_ray.is_colliding(): # ground indicator shadow
		var hit_pos = ground_ray.get_collision_point()
		ground_shadow.global_position = hit_pos + Vector3.UP * 0.15
		var height = global_position.y - hit_pos.y
		ground_shadow.scale = Vector3.ONE * clamp(1.2 - height * 0.2, 0.4, 2.0)

func _physics_process(delta: float) -> void:
	if is_movement == false:
		return
	match state:
		State.NORMAL:
			handle_normal_movement(delta)
		State.BUILDING:
			build_system.position_ghost_block()
			handle_normal_movement(delta)
		State.CLIMBING:
			climbing_system.handle_climb_movement(delta)
		State.PARACHUTE:
			parachute_system.handle_parachute_movement(delta)
		State.GLIDING:
			gliding_system.update_glider_tilt()
			if is_on_floor():
				handle_normal_movement(delta)
			else:
				gliding_system.handle_gliding_movement(delta)
	_poll_water_state(delta)
	_poll_running_state()
	if state != State.CLIMBING:
		move_and_slide()
		
		
# Input/Movement
func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		global_transform = get_parent().spawn_point.global_transform
		camera_system.sync_camera()
	if event.is_action_pressed("checkpoint"):
		get_parent().goto_cur_checkpoint(self)
	if event.is_action_pressed("interact"):
		interact_held = true
		hold_timer = 0.0 # counting in _process
		hold_triggered = false
	elif event.is_action_released("interact"):
		if not hold_triggered:
			_try_interact_action()
		else:
			_try_interact_action_held_released()
		interact_held = false

	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("toggle_inventory_menu"):
		Signals.toggle_inventory_menu.emit()
	if Input.is_action_just_pressed("toggle_building_menu"):
		Signals.toggle_build_menu.emit()
	if Input.is_action_just_pressed("exit_vehicle"):
		gliding_system.exit_glider()
		
func _poll_running_state() -> void:
	var wants_to_run := Input.is_action_pressed("run")
	if not wants_to_run and is_on_floor(): # only slow on ground
		is_running = false
	elif is_on_floor() and water_count <= 0: # only speed on ground (and no water)
		is_running = true	

# Water
func enter_water(dir: Vector3, speed: float) -> void:
	water_count += 1
	in_water = true
	water_flow_dir = dir
	water_flow_speed = speed
	is_running = false

func exit_water() -> void:
	water_count -= 1
	if water_count <= 0:
		water_count = 0
		in_water = false
		water_flow_dir = Vector3.ZERO
		water_flow_speed = 0.0
		
func _poll_water_state(delta) -> void:
	water_poll_accum += delta
	if water_poll_accum >= WATER_POLL_INTERVAL:
		water_poll_accum = 0.0
		_update_water_state()
		
func _update_water_state():
	var areas : Array[Area3D] = $WaterDetectArea.get_overlapping_areas()
	if areas.is_empty():
		in_water = false
		water_flow_dir = Vector3.ZERO
		water_flow_speed = 0.0
		return
	in_water = true
	var flow_sum := Vector3.ZERO
	var max_speed := 0.0
	for area in areas:
		var water = area.get_parent().get_parent()
		if not water.has_method("get_flow_dir"):
			continue
		var dir : Vector3 = water.get_flow_dir()
		var speed : float = water.flow_speed
		flow_sum += dir * speed
		max_speed = max(max_speed, speed)
	if flow_sum != Vector3.ZERO:
		water_flow_dir = flow_sum.normalized()
		water_flow_speed = max_speed
	else:
		water_flow_dir = Vector3.ZERO
		water_flow_speed = 0.0

# States
func set_state(new_state):
	if state == new_state:
		return
	state = new_state

# State.NORMAL
func handle_normal_movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += _get_gravity(velocity) * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jump_available and not coyote_timer.is_stopped(): # coyote jump
			jump()
		else:
			jump_buffer_timer.start()
	if is_on_floor():
		if is_in_air: # must check this before jump buffer
			animation_system.jump_animation.play("land")
		is_in_air = false
		jump_available = true
		if not jump_buffer_timer.is_stopped(): # regular / buffer jump
			jump()
			
	# this must be run before so that its is_on_floor is updated and
	# can compare this frame's is_on_floor with last frame's was_on_floor
	if was_on_floor and not is_on_floor() and velocity.y <= 0:
		coyote_timer.start()
		is_in_air = true
	# this must run after because move_and_slide() will be called
	# at the end of this function, updating is_on_floor
	was_on_floor = is_on_floor()
	
	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y = JUMP_VELOCITY / 4.0  # slow accent on release

	# Crouch
	if Input.is_action_just_pressed("crouch"):
		crouch()
	elif is_crouching and not Input.is_action_pressed("crouch"):
		uncrouch()
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Velocity
	var target_velocity : Vector3
	if is_running:
		target_velocity = Vector3(direction.x * RUN_SPEED, velocity.y, direction.z * RUN_SPEED)
	else: # not running
		target_velocity = Vector3(direction.x * SPEED, velocity.y, direction.z * SPEED)
	if in_water:
		target_velocity += water_flow_dir * (SPEED * water_flow_speed * 4)
	if in_wind_hazard:
		var wind_velocity = target_velocity + wind_flow_dir * (SPEED * wind_flow_speed * 4)
		target_velocity = target_velocity.move_toward(wind_velocity, wind_acceleration * delta)
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z	

func _get_gravity(v: Vector3):
	if v.y < 0:
		return GRAVITY
	return FALL_GRAVITY

func jump() -> void:
	jump_available = false
	is_in_air = true
	coyote_timer.stop()
	jump_buffer_timer.stop()
	velocity.y = JUMP_VELOCITY
	animation_system.jump_animation.play("jump")

func crouch() -> void:
	delay_uncrouch = false
	if not is_crouching:
		is_crouching = true
		animation_system.crouch_animation.play("crouch")

func uncrouch() -> void:
	if uncrouch_timer.is_stopped():
		uncrouch_timer.start() # reduce checking
		if crouch_detect.is_colliding():
			delay_uncrouch = true
		else: #not crouch_detect.is_colliding():
			is_crouching = false
			delay_uncrouch = false
			animation_system.crouch_animation.play_backwards("crouch")


# Crafting
func _on_craft_remove(items: Array):
	for item in items:
		remove_from_inventory(item)

func _on_craft_add(items: Array):
	for item in items:
		add_to_inventory(item)

func add_to_inventory(item: Item):
	inventory.append(item)
	Signals.inventory_changed.emit(inventory)
	if not inventory_tutorial_found_item:
		inventory_tutorial_found_item = true
		Signals.msg_sent.emit("It looks like you found an "+item.display_name+". Press 'i' to open your inventory.")

func remove_from_inventory(item: Item):
	inventory.erase(item)
	Signals.inventory_changed.emit(inventory)

# Interacting
var nearby_interactable = null
func set_nearby_interactable(obj):
	nearby_interactable = obj

func clear_nearby_interactable(obj):
	if nearby_interactable == obj:
		nearby_interactable = null
	
func _try_interact_action():
	if nearby_interactable:
		nearby_interactable.interact_action(self)
	else:
		Signals.msg_sent.emit("Nothing nearby")

func _try_interact_action_held():
	if nearby_interactable and nearby_interactable.has_method("interact_action_held"):
		nearby_interactable.interact_action_held()
	else:
		Signals.msg_sent.emit("Nothing with interact nearby")

func _try_interact_action_held_released():
	Signals.close_wheel.emit()
	
func _on_wheel_selection(selection: ItemAction):
	if nearby_interactable and nearby_interactable.has_method("interact_action_held"):
		nearby_interactable.on_wheel_selection(self, selection)
