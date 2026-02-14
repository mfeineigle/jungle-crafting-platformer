# NOTE the TOP/BOTTOM are reversed on the rope versus the ladder
# because of the negative segment_height (to make it grow down)
extends Node3D

@export var item_path: String
@export var rope_segment_scene: PackedScene
@export var rope: PackedScene
var buildable_prototype: Buildable
@export var segment_height: float = -1.0
@export var min_segments: int = 1

var current_height: int = 3
var segments: Array = []

func _ready():
	buildable_prototype = rope.instantiate() as Buildable
	update_preview()
	
func get_buildable() -> Buildable:
	return buildable_prototype
	
func destroy():
	queue_free()
	
func assemble_segments():
	var final_rope = rope.instantiate()
	final_rope.current_height = current_height
	return final_rope
	
func _unhandled_input(event):
	var ctrl = Input.is_key_pressed(KEY_CTRL)
	if ctrl:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			current_height = clamp(current_height-1, 1, 100)
			update_preview()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			current_height = clamp(current_height+1, 1, 100)
			update_preview()


func update_preview():
	# Remove old segments
	for seg in segments:
		seg.queue_free()
	segments.clear()
	
	# Spawn new segments stacked vertically
	for i in range(current_height):
		var seg = rope_segment_scene.instantiate()
		seg.position = Vector3(0, i * segment_height, 0)
		add_child(seg)
		segments.append(seg)
