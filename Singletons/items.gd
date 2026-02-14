extends Node

@export var vine: Item
@export var stick: Item
@export var rope: Item

func _ready():
	if vine == null:
		vine = load("res://Items/Resources/vine.tres")
	if stick == null:
		stick = load("res://Items/Resources/stick.tres")
	if rope == null:
		rope = load("res://Items/Resources/rope.tres")
