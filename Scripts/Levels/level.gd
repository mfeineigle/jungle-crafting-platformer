extends Node3D
class_name Level

@export var check_points: Array[Checkpoint]
@onready var spawn_point: Marker3D = $spawn_point
var cur_check_point: Checkpoint = null

func _ready():
	add_to_group("level")

func goto_cur_checkpoint(player: Player):
	if cur_check_point:
		player.global_position = cur_check_point.global_position
		player.global_rotation = cur_check_point.global_rotation
		player.camera_system.sync_camera()
	
# Called by Root after this level is added
func take_player():
	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_error("No player found!")
		return
		
	var old_parent = player.get_parent()
	if player.get_parent() != self:
		old_parent.remove_child(player) # get old level
		add_child(player) # add player to new level
		_position_player_at_spawn_point(player)
		player.camera_system.sync_camera()
		_on_player_taken(player) # optional features from subclasses
		if old_parent and old_parent != get_tree().get_root().get_node("Root/World"):
			old_parent.queue_free()  # remove old level

func _position_player_at_spawn_point(player):
	player.global_transform = spawn_point.global_transform
	player.velocity = Vector3.ZERO
	player.is_movement = true

## Default optional features
@warning_ignore("unused_parameter")
func _on_player_taken(player):
	pass
