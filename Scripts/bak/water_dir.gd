@tool
extends Node3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export_range(0, 7) var flow_dir_index: int = 0 : set = set_flow_dir_index
@export_range(0, 7) var flow_speed: float = 0.0 : set = set_flow_speed

func _ready() -> void:
	_apply_shader_params()
	
func set_flow_dir_index(value: int):
	flow_dir_index = value
	_apply_shader_params()
	
func set_flow_speed(value: float):
	flow_speed = value
	_apply_shader_params()

func _apply_shader_params() -> void:
	if mesh:
		mesh.set_instance_shader_parameter("flow_speed", flow_speed)
		mesh.set_instance_shader_parameter("flow_dir_index", flow_dir_index)
