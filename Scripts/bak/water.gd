@tool
extends Node3D
@onready var mesh: MeshInstance3D = $water_mesh
@onready var area: Area3D = $water_mesh/Area3D

enum FlowDir {
	N, ## North
	NE, ## Northeast
	E, ## East
	SE, ## Southeast
	S, ## South
	SW, ## Southwest
	W, ## West
	NW, ## Northwest
	DOWN, ## Down
	UP, ## UP
}
## Direction of the water flow
@export var flow_dir_index: FlowDir = FlowDir.N : set = set_flow_dir_index
@export_range(0, 7) var flow_speed: float = 0.0 : set = set_flow_speed


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_apply_shader_params()
	
func set_flow_dir_index(value: FlowDir):
	flow_dir_index = value
	_apply_shader_params()
	
func set_flow_speed(value: float):
	flow_speed = value
	_apply_shader_params()

func _apply_shader_params() -> void:
	if mesh:
		mesh.set_instance_shader_parameter("flow_speed", flow_speed)
		mesh.set_instance_shader_parameter("flow_dir_index", flow_dir_index)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print(body, " entered the water")
		body.in_water = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		print(body, " left the water")
		body.in_water = false
