extends Node3D

@onready var collision: CollisionShape3D = $Area3D/CollisionShape3D
@onready var area: Area3D = $Area3D

@export var height: float = 15.0
@export var radius: float = 3.0

func _ready():
	collision.shape.height = height
	collision.shape.radius = radius
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)
	
func _on_area_body_entered(body):
	body.gliding_system.in_updraft = true

func _on_area_body_exited(body):
	body.gliding_system.in_updraft = false
