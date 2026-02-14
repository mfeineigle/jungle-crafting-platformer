extends Node

signal wind_strength_changed(strength: float)
signal wind_state_changed(state: int) #not used

enum State { CALM, RAMP_UP, STRONG, RAMP_DOWN }

var state: State = State.CALM
var strength: float = 0.0:
	get:
		return strength
	set(value):
		strength = value
		wind_strength_changed.emit(strength)

@export var max_strength := 1.0
@export var ramp_time := 5.0
@export var strong_duration := 3.0
@export var calm_duration := 4.0


func _ready() -> void:
	_change_state(State.CALM)

	
func _change_state(new_state: State) -> void:
	state = new_state
	emit_signal("wind_state_changed", state)

	match state:
		State.CALM:
			_run_calm()
		State.RAMP_UP:
			_run_ramp_up()
		State.STRONG:
			_run_strong()
		State.RAMP_DOWN:
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
	
