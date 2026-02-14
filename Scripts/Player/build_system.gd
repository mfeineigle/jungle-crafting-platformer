# State.BUILDING
extends Node3D

@onready var player: Player = $".."
var built_something: bool = false

@onready var placement_target: Marker3D = $"../PlacementTarget"
@onready var camera: Camera3D = $"../CameraSystem/VerticalSpringArm/HorizontalSpringArm/Camera3D"
@onready var vertical_spring_arm: SpringArm3D = $"../CameraSystem/VerticalSpringArm"

var grid_size = 0.25
var ghost_block: Node3D = null
var build_offset_y : float = 0.0
var is_ground_snapped := false
var is_wall_snapped := false

func _ready() -> void:
	Signals.spawn_ghost_block.connect(spawn_ghost_block)
	
func spawn_ghost_block(item: Item) -> void:
	player.set_state(player.State.BUILDING)
	player.remove_from_inventory(item)
	ghost_block = (item.buildable).instantiate()
	player.get_parent().add_child(ghost_block)
	ghost_block.global_position = placement_target.global_position
	build_offset_y = item.build_offset_y
	
func position_ghost_block():
	_set_ghost_block_position()
	_snap_position()
	_apply_preview_material_recursive(ghost_block)
	_handle_ghost_block_inputs()

func _set_ghost_block_position() -> void:
	var snap_pos: Vector3 = _snap_to_grid(placement_target.global_position, grid_size)
	ghost_block.global_position.x = lerp(ghost_block.global_position.x, snap_pos.x, 0.1)
	ghost_block.global_position.z = lerp(ghost_block.global_position.z, snap_pos.z, 0.1)
	
func _snap_to_grid(pos: Vector3, grid_snap: float) -> Vector3:
	var x = round(pos.x / grid_snap) * grid_snap
	var y = round(pos.y / grid_snap) * grid_snap
	var z = round(pos.z / grid_snap) * grid_snap
	return Vector3(x, y, z)

func _snap_position():
	var target_y: float = self.global_position.y + build_offset_y
	var pos :Vector3 = ghost_block.global_position

	match ghost_block.get_buildable().snap_mode:
		Buildable.SnapMode.FLOOR:
			target_y = _try_snap_to_floor(target_y)
		Buildable.SnapMode.WALL:
			pos = _try_snap_to_wall(pos)
			ghost_block.global_position = pos
		Buildable.SnapMode.CEILING:
			pass
		_:
			print("Uh-oh, snapping gone crazy.")
	ghost_block.global_position.y = target_y
	
func _try_snap_to_floor(target_y):
	var ray_origin := ghost_block.global_position + Vector3(0.0, 1, 0.0)
	var ground_y := _get_ground_snap_y(ray_origin)
	if ground_y != INF:
		if not is_ground_snapped:
			if abs(target_y - ground_y) <= 0.75:
				is_ground_snapped = true
		else:
			# stay snapped unless clearly broken
			if abs(target_y - ground_y) > 1.25:
				is_ground_snapped = false
		if is_ground_snapped:
			target_y = ground_y
	else:
		is_ground_snapped = false
	return target_y
	
func _get_ground_snap_y(from_pos: Vector3, max_distance := 5.0) -> float:
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		from_pos,
		from_pos + Vector3.DOWN * max_distance
	)
	query.exclude = [ghost_block]
	query.collision_mask = (1 << 0)#GROUND_MASK # define this
	var result := space.intersect_ray(query)
	if result:
		return result.position.y
	return INF

func _try_snap_to_wall(pos: Vector3) -> Vector3:
	var space := get_world_3d().direct_space_state
	# direction player is aiming / ghost is facing
	var dir := -ghost_block.global_transform.basis.z.normalized()
	var ray_origin := pos
	var ray_end := ray_origin + dir * 2.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [ghost_block]
	query.collision_mask = (1 << 0)
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))
	if hit.is_empty():
		is_wall_snapped = false
		return pos
	var normal: Vector3 = hit.normal
	if not _is_wall(normal):
		is_wall_snapped = false
		return pos
	var snap_dist:float = abs((hit.position - pos).dot(normal))
	if not is_wall_snapped:
		if snap_dist <= 0.5:
			is_wall_snapped = true
	else:
		if snap_dist > 0.9:
			is_wall_snapped = false
	if not is_wall_snapped:
		return pos
	# Project position onto wall plane
	var offset := 0.5
	return hit.position + normal * offset
	
func _is_wall(normal: Vector3) -> bool:
	return abs(normal.dot(Vector3.UP)) < 0.2

	
func _apply_preview_material_recursive(root: Node) -> void:
	if root is MeshInstance3D:
		_apply_preview_to_mesh(root)
	for child in root.get_children():
		_apply_preview_material_recursive(child)
		
func _apply_preview_to_mesh(mesh: MeshInstance3D) -> void:
	var mat: BaseMaterial3D = null
	# 1. If already has an override, duplicate it
	if mesh.material_override:
		mat = mesh.material_override.duplicate()
	# 2. Otherwise, use the first surface material
	elif mesh.mesh and mesh.mesh.get_surface_count() > 0:
		var surf_mat = mesh.mesh.surface_get_material(0)
		if surf_mat:
			mat = surf_mat.duplicate()
	# 3. Skip if no material
	if not mat:
		return
	# Semi-transparent preview
	mat.albedo_color.a = 0.5
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Stencil settings
	mat.stencil_mode = BaseMaterial3D.STENCIL_MODE_XRAY
	mat.stencil_color = Color.RED
	# Assign override
	mesh.material_override = mat
	
func _handle_ghost_block_inputs() -> void:
	if Input.is_action_just_pressed("cancel"):
		_cancel_ghost_block()
	if Input.is_key_pressed(KEY_CTRL):
		if Input.is_action_just_pressed("lower_block"):
			build_offset_y -= 0.1
		elif Input.is_action_just_pressed("raise_block"):
			build_offset_y += 0.1
	if Input.is_action_just_pressed("rotate"):
		ghost_block.rotation.y += deg_to_rad(90)
	if Input.is_action_just_pressed("left_click"):# and ghost_block.can_place():
		_solidify_ghost_block()
		
func _cancel_ghost_block() -> void:
	player.add_to_inventory(load(ghost_block.item_path))
	ghost_block.queue_free()
	player.set_state(player.State.NORMAL)

func _solidify_ghost_block() -> void:
	if not _can_place_block():
		Signals.msg_sent.emit("Can't place "+ghost_block.get_buildable().display_name+" here.")
		return
	var actual_block: Node3D
	if ghost_block.get("segments"): #ladders and ropes
		actual_block = ghost_block.assemble_segments()
	else:
		actual_block = load(ghost_block.scene_file_path).instantiate()
	player.get_parent().add_child(actual_block)
	actual_block.global_transform.origin = ghost_block.global_transform.origin
	actual_block.global_rotation = ghost_block.global_rotation
	actual_block.name = ghost_block.name
	ghost_block.destroy()
	if not built_something:
		Signals.msg_sent.emit("Press 'e' to interact with your "+ghost_block.get_buildable().display_name+". Press and hold 'e' for more options.")
		built_something = true
	player.set_state(player.State.NORMAL)
	
func _can_place_block() -> bool:
	# grab the placement shapes
	var placement_shapes: Array[CollisionShape3D]
	const placement_path: String = "placement_body/placement_col"
	if ghost_block.has_node(placement_path):
		placement_shapes.append(ghost_block.get_node(placement_path))
	else:
		for node in ghost_block.get_children():
			placement_shapes.append(node.get_node(placement_path))
	var space = get_world_3d().direct_space_state
	# Test each shape individually
	for col in placement_shapes:
		var params = PhysicsShapeQueryParameters3D.new()
		params.shape = col.shape
		params.transform = col.global_transform
		const PLACEMENT_BLOCKING_MASK := (1 << 0) | (1 << 2)
		params.collision_mask = PLACEMENT_BLOCKING_MASK
		if not space.intersect_shape(params, 1).is_empty():
			return false
	return true
