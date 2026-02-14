@tool
extends MeshInstance3D

@onready var liquid_tile := get_parent() as Node3D

func _enter_tree():
	if Engine.is_editor_hint():  # editor only
		liquid_tile.liquid_changed.connect(_apply_shader_params)
		_apply_shader_params()
	
func _ready():
	_apply_shader_params()
		
func _apply_shader_params():
	set_instance_shader_parameter("flow_speed", liquid_tile.flow_speed)
	set_instance_shader_parameter("flow_dir_index", liquid_tile.flow_dir)
