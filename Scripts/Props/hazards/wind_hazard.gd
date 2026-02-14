extends Node3D
@onready var area: Area3D = $Area3D
@onready var particles: GPUParticles3D = $GPUParticles3D

## Global direction to push in
@export var wind_flow_dir: Vector3
@export var wind_flow_speed: float = 4.0
## Ramp speed, lower = slower
@export var wind_ramp_speed: float = 0.5

var _old_wind_acceleration: float
var is_wind_blowing: bool


var _target_visual_strength: float = 0.0
var _current_visual_strength: float = 0.0
var _original_aabb: AABB

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	Wind.wind_strength_changed.connect(_on_wind_strength_changed)
	particles.emitting = false
	_original_aabb = particles.visibility_aabb


func _on_wind_strength_changed(strength) -> void:
	if strength > 0.1:
		particles.amount = 40
		particles.emitting = true
		_target_visual_strength = clamp(strength / 0.5, 0.0, 1.0)
	else:
		_target_visual_strength = 0.0
		
	if strength >= 0.5:
		is_wind_blowing = true
	else:
		is_wind_blowing = false
		
	
func _on_body_entered(body) -> void:
	if body.is_in_group("player") and is_wind_blowing:
		_old_wind_acceleration = body.wind_acceleration
		body.in_wind_hazard = true
		body.wind_flow_dir = wind_flow_dir
		body.wind_flow_speed = wind_flow_speed
		body.wind_acceleration = 4000.0

func _on_body_exited(body) -> void:
	if body.is_in_group("player"):
		await get_tree().create_timer(1.5).timeout
		body.in_wind_hazard = false
		body.wind_acceleration = _old_wind_acceleration
		
func _process(delta: float) -> void:
	_current_visual_strength = move_toward(
		_current_visual_strength,
		_target_visual_strength,
		wind_ramp_speed * delta   # ← ramp speed (lower = slower)
	)
	particles.amount_ratio = _current_visual_strength
	particles.speed_scale = _current_visual_strength
	# Turn off emission only after fully faded
	if _current_visual_strength <= 0.5 and _target_visual_strength == 0.0:
		particles.amount = 1
		particles.emitting = false
	
		
		
		
		
		
