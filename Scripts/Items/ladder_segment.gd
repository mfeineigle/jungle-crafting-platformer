extends Node3D

@export var item_path: String
@export var actions: Array[ItemAction]

# Top
@onready var top_front_area: Area3D = $areas/top_front_area
@onready var top_front_col: CollisionShape3D = $areas/top_front_area/top_front_col
@onready var top_back_area: Area3D = $areas/top_back_area
@onready var top_back_col: CollisionShape3D = $areas/top_back_area/top_back_col
# Bottom
@onready var bottom_front_area: Area3D = $areas/bottom_front_area
@onready var bottom_front_col: CollisionShape3D = $areas/bottom_front_area/bottom_front_col
@onready var bottom_back_area: Area3D = $areas/bottom_back_area
@onready var bottom_back_col: CollisionShape3D = $areas/bottom_back_area/bottom_back_col

var enter_marker: Marker3D = null
var exit_marker: Marker3D = null

func _ready():
	var areas = [
		top_front_area,
		top_back_area,
		bottom_front_area,
		bottom_back_area
	]
	for area in areas:
		area.body_entered.connect(_on_body_entered.bind(area), CONNECT_REFERENCE_COUNTED)
		area.body_exited.connect(_on_body_exited.bind(area), CONNECT_REFERENCE_COUNTED)

# only enable areas for the top/bottom segments
enum SegmentType { MIDDLE, BOTTOM, TOP }
func setup(type: SegmentType) -> void:
	top_front_col.disabled = type != SegmentType.TOP
	top_back_col.disabled = type != SegmentType.TOP
	bottom_front_col.disabled = type != SegmentType.BOTTOM
	bottom_back_col.disabled = type != SegmentType.BOTTOM
	
enum Side { FRONT, BACK }
# check if any area on a side is blocked
func is_side_blocked(side: Side) -> bool:
	var areas := []
	if side == Side.FRONT:
		areas = [top_front_area, bottom_front_area]
	else:
		areas = [top_back_area, bottom_back_area]
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
	if side == Side.FRONT:
		areas = [top_front_area, bottom_front_area]
	else:
		areas = [top_back_area, bottom_back_area]
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
		player.climbing_system.enter_ladder(self)
	elif player.state == player.State.CLIMBING and exit_marker != null:
		player.climbing_system.exit_ladder(self)

func interact_action_held():
	Signals.open_wheel.emit(actions)
	
func on_wheel_selection(player: Player, selection: ItemAction):
	var ctx = {"player":player,
				"object":self,
				}
	selection.execute(ctx)
			
func destroy():
	queue_free()
