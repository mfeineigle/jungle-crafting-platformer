# Buildable.gd
extends Node3D
class_name Buildable

enum SnapMode {
	NONE,
	FLOOR,
	CEILING,
	WALL,
}

@export var display_name: String
@export var snap_mode: SnapMode = SnapMode.NONE
@export var snap_enter_distance := 0.75
@export var snap_exit_distance := 1.25

func get_buildable() -> Buildable:
	return self
