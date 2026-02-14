extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

@export var target: Node3D

@export var max_strength := 1.0
@export var ramp_time := 5.0
@export var strong_duration := 3.0
@export var calm_duration := 4.0

enum State { CALM, RAMP_UP, STRONG, RAMP_DOWN }

var state: State = State.CALM
var strength: float = 0.0:
	get:
		return strength
	set(value):
		strength = value
		target._on_wind_strength_changed(strength)
		
func _ready() -> void:
	particles.emitting = false
	_change_state(State.CALM)

	
func _change_state(new_state: State) -> void:
	state = new_state

	match state:
		State.CALM:
			print("calm")
			_run_calm()
		State.RAMP_UP:
			print("ramp up")
			_run_ramp_up()
		State.STRONG:
			print("strong")
			_run_strong()
		State.RAMP_DOWN:
			print("ramp down")
			_run_ramp_down()


func _run_calm() -> void:
	strength = 0.0
	await get_tree().create_timer(calm_duration).timeout
	_change_state(State.RAMP_UP)

func _run_ramp_up() -> void:
	var tween = create_tween()
	tween.tween_property(self, "strength", max_strength, ramp_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_change_state(State.STRONG)
	
func _run_strong() -> void:
	strength = max_strength
	await get_tree().create_timer(strong_duration).timeout
	_change_state(State.RAMP_DOWN)
	
func _run_ramp_down() -> void:
	var tween = create_tween()
	tween.tween_property(self, "strength", 0.0, ramp_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_change_state(State.CALM)
