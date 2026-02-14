extends Node3D

@onready var mesh_nodes := []
@export var wind_direction: Vector3 = Vector3(1,0,0) # default global direction

func _ready() -> void:
	Wind.wind_state_changed.connect(_on_wind_state_changed)
	Wind.wind_strength_changed.connect(_on_wind_strength_changed)
	# find all meshes with "vine" in the name
	for child in get_children():
		if child is MeshInstance3D and "vine" in str(child.name).to_lower():
			mesh_nodes.append(child)
	for mesh in mesh_nodes:
		# assign the shader material
		var mat = preload("res://Assets/materials/wind_vine_shader_material.tres").duplicate(true) as ShaderMaterial
		mesh.material_override = mat
		# transform global wind direction into the mesh's local space
		var local_dir = mesh.transform.basis.inverse() * wind_direction
		mat.set_shader_parameter("wind_direction", local_dir)
		# random phase offset so vines sway asynchronously
		var random_phase = randf() * TAU  # TAU = 2 * PI
		mat.set_shader_parameter("phase_offset", random_phase)

func _on_wind_strength_changed(strength: float) -> void:
	for mesh in mesh_nodes:
		var mat := mesh.material_override as ShaderMaterial
		if mat:
			mat.set_shader_parameter("wind_strength", strength)

func _on_wind_state_changed(state) -> void:
	pass
	#print(state)
