# NOTE the TOP/BOTTOM are reversed on the rope versus the ladder
# because of the negative segment_height (to make it grow down)
extends Buildable

@export var rope_segment_scene: PackedScene
@export var segment_height: float = -1.0
var current_height: int = 0
var segments: Array = []

func _ready() -> void:
	# Spawn new segments stacked vertically
	for i in range(current_height):
		var seg = rope_segment_scene.instantiate()
		seg.position = Vector3(0, i * segment_height, 0)
		add_child(seg)
		var type : int = seg.SegmentType.MIDDLE
		if i == 0:
			type = seg.SegmentType.BOTTOM
		elif i == current_height - 1:
			type = seg.SegmentType.TOP
		seg.setup(type)
		segments.append(seg)
	# disable all of a side if any of the areas are blocked
	await get_tree().physics_frame
	_check_blocked_sides()


# interface with each segment to check its areas
func _check_blocked_sides():
	for seg in segments:
		if seg.is_side_blocked(seg.Side.ONE):
			_disable_side_all_segments(seg.Side.ONE)
		if seg.is_side_blocked(seg.Side.TWO):
			_disable_side_all_segments(seg.Side.TWO)
		if seg.is_side_blocked(seg.Side.THREE):
			_disable_side_all_segments(seg.Side.THREE)

# disable sides with blocked areas
func _disable_side_all_segments(side):
	for seg in segments:
		seg.disable_side(side)
