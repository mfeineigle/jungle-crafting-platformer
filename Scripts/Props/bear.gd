extends CharacterBody3D

@export var path: Path3D
@export var speed: float = 6.0

@onready var follow = path.get_node("PathFollow3D")
@onready var path_length = path.curve.get_baked_length()
var EPSILON: float = 0.5 # wiggle room on path_length

var is_tripped: bool = false

func _ready() -> void:
	Signals.trap_triggered.connect(_on_trap_triggered)
	set_physics_process(false)  # disable to start


func _on_trap_triggered(trap) -> void:
	if trap == self:
		is_tripped = true
		set_physics_process(true)  # enable

func _physics_process(delta: float) -> void:
	follow.progress += speed * delta
	global_position = follow.global_position
	global_rotation = follow.global_rotation

	# Stop at the end
	if follow.progress >= path_length - EPSILON:
		follow.progress = path_length
		set_physics_process(false)  # disable when done
		
