# NOTE the TOP/BOTTOM are reversed on the rope versus the ladder
# because of the negative segment_height (to make it grow down)
extends Node3D

@export var actions: Array[ItemAction]
@export var item_path: String

# Top
@onready var top_one_area: Area3D = $areas/top_one_area
@onready var top_one_col: CollisionShape3D = $areas/top_one_area/top_one_col
@onready var top_two_area: Area3D = $areas/top_two_area
@onready var top_two_col: CollisionShape3D = $areas/top_two_area/top_two_col
@onready var top_three_area: Area3D = $areas/top_three_area
@onready var top_three_col: CollisionShape3D = $areas/top_three_area/top_three_col
# Bottom
@onready var bottom_one_area: Area3D = $areas/bottom_one_area
@onready var bottom_one_col: CollisionShape3D = $areas/bottom_one_area/bottom_one_col
@onready var bottom_two_area: Area3D = $areas/bottom_two_area
@onready var bottom_two_col: CollisionShape3D = $areas/bottom_two_area/bottom_two_col
@onready var bottom_three_area: Area3D = $areas/bottom_three_area
@onready var bottom_three_col: CollisionShape3D = $areas/bottom_three_area/bottom_three_col

var enter_marker: Marker3D = null
var exit_marker: Marker3D = null


func _ready():
	var areas = [
		top_one_area,
		top_two_area,
		top_three_area,
		bottom_one_area,
		bottom_two_area,
		bottom_three_area,
	]
	for area in areas:
		area.body_entered.connect(_on_body_entered.bind(area), CONNECT_REFERENCE_COUNTED)
		area.body_exited.connect(_on_body_exited.bind(area), CONNECT_REFERENCE_COUNTED)
		
# only enable areas for the top/bottom segments
enum SegmentType { MIDDLE, BOTTOM, TOP }
func setup(type: SegmentType) -> void:
	top_one_col.disabled = type != SegmentType.BOTTOM
	top_two_col.disabled = type != SegmentType.BOTTOM
	top_three_col.disabled = type != SegmentType.BOTTOM
	bottom_one_col.disabled = type != SegmentType.TOP
	bottom_two_col.disabled = type != SegmentType.TOP
	bottom_three_col.disabled = type != SegmentType.TOP	
	
enum Side { ONE, TWO, THREE }
# check if any area on a side is blocked
func is_side_blocked(side: Side) -> bool:
	var areas := []
	if side == Side.ONE:
		areas = [top_one_area, bottom_one_area]
	elif side == Side.TWO:
		areas = [top_two_area, bottom_two_area]
	else:
		areas = [top_three_area, bottom_three_area]
	for area in areas:
		if not area.monitoring:
			continue
		for body in area.get_overlapping_bodies():
			if body.collision_layer & (1 << 0):
				return true
	return false

# if is_side_blocked(), disable the entire side
func disable_side(side):
	var areas := []
	if side == Side.ONE:
		areas = [top_one_area, bottom_one_area]
	if side == Side.TWO:
		areas = [top_two_area, bottom_two_area]
	else:
		areas = [top_three_area, bottom_three_area]
	for area in areas:
		area.monitoring = false
		for child in area.get_children():
			if child is CollisionShape3D:
				child.disabled = true
				
				
func _on_body_entered(body, area):
	if body.is_in_group("player"):
		body.set_nearby_interactable(self)
		enter_marker = area.get_node("enter_marker")
		exit_marker = area.get_node("exit_marker")
		var msg: String = "ENTER "+area.name+" the enter marker is "+area.get_node("enter_marker").name+" the exit marker is "+area.get_node("exit_marker").name
		Globals.dprint(Globals.DebugChannel.BUILDING, msg)

func _on_body_exited(body, area):
	if body.is_in_group("player"):
		body.clear_nearby_interactable(self)
		enter_marker = null
		exit_marker = null
		var msg: String = "EXIT "+area.name+" the enter marker is "+area.get_node("enter_marker").name+" the exit marker is "+area.get_node("exit_marker").name
		Globals.dprint(Globals.DebugChannel.BUILDING, msg)

func interact_action(player):
	if player.state == player.State.NORMAL and enter_marker != null:
		player.climbing_system.enter_rope(self)
	elif player.state == player.State.CLIMBING and exit_marker != null:
		player.climbing_system.exit_rope(self)

func interact_action_held():
	Signals.open_wheel.emit(actions)
	
func on_wheel_selection(player: Player, selection: ItemAction):
	var ctx = {"player":player,
				"object":self,
				}
	selection.execute(ctx)

func destroy():
	queue_free()
