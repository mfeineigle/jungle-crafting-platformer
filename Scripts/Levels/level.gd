extends Node3D
class_name Level

@export var player_scene: PackedScene
@export var check_points: Array[Checkpoint]
@onready var spawn_point: Marker3D = $spawn_point
var cur_check_point: Checkpoint = null

func _ready():
	add_to_group("level")
	Signals.reload_checkpoint.connect(goto_cur_checkpoint)

func goto_cur_checkpoint(player: Player):
	if cur_check_point:
		player.global_position = cur_check_point.global_position
		player.global_rotation = cur_check_point.global_rotation
		player.camera_system.sync_camera()
	
# Called by Root after this level is added
func take_player():
	var player = get_tree().get_first_node_in_group("player") as Player
	var old_parent: Node = null
	
	if not player:
		player = player_scene.instantiate() as Player
	else:
		old_parent = player.get_parent()
		old_parent.remove_child(player)
	
	add_child(player)
	_position_player_at_spawn_point(player)
	player.camera_system.sync_camera()
	_on_player_taken(player)
	
	# Find and free any existing level that isn't this one
	var world = get_tree().get_root().get_node("Root/World")
	for child in world.get_children():
		if child.is_in_group("level") and child != self:
			child.queue_free()


func _position_player_at_spawn_point(player):
	player.global_transform = spawn_point.global_transform
	player.velocity = Vector3.ZERO
	player.is_movement = true

## Default optional features
@warning_ignore("unused_parameter")
func _on_player_taken(player):
	pass
