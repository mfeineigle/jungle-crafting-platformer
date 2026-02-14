extends Node3D
@onready var detect_area: Area3D = $vine/DetectArea
@export var item: Item


func _ready():
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player near vine")
		body.set_nearby_interactable(self)

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Player no longer near vine")
		body.clear_nearby_interactable(self)
		
func interact(player):
	print("Interacted with vine")
	queue_free()
	player.add_to_inventory(item)
