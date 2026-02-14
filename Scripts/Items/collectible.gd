class_name Collectible
extends Node3D
@export var detect_area: Area3D
@export var item: Item


func _ready():
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_nearby_interactable(self)

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.clear_nearby_interactable(self)
		
func interact_action(player: Player):
	if player.inventory_tutorial_found_item:
		Signals.learned_recipe.emit(item)
	queue_free()
	player.add_to_inventory(item)
