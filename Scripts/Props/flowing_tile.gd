@tool
extends Node3D

signal liquid_changed #this signal is only used on a liquid tile

## Direction of the liquid flow
@export var flow_dir: FlowDir = FlowDir.N : set = set_flow_dir

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
	UP, ## Up
}

func set_flow_dir(value: FlowDir):
	flow_dir = value
	liquid_changed.emit()

## Returns the opposite direction of the flow used in shader (correct in world space)
func get_flow_dir():
	return -FLOW_DIR_VECTORS[flow_dir].normalized()
	
const FLOW_DIR_VECTORS := [
	Vector3( 0, 0, -1), # N
	Vector3( 1, 0, -1), # NE
	Vector3( 1, 0,  0), # E
	Vector3( 1, 0,  1), # SE
	Vector3( 0, 0,  1), # S
	Vector3(-1, 0,  1), # SW
	Vector3(-1, 0,  0), # W
	Vector3(-1, 0, -1), # NW
	Vector3( 0,-1,  0), # DOWN
	Vector3( 0, 1,  0), # UP
]


## Speed of the liquid flow
@export_range(0, 1, 0.1) var flow_speed: float = 0.0 : set = set_flow_speed
	
func set_flow_speed(value: float):
	flow_speed = value
	liquid_changed.emit()
