extends Buildable

@onready var detect_area: Area3D = $detect_area
@export var item_path: String # break circular dependency of glider item/buildable
@export var actions: Array[ItemAction]

func _ready() -> void:
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_nearby_interactable(self)

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.clear_nearby_interactable(self)
		
func destroy():
	queue_free()
	
func interact_action(player: Player):
	get_parent().remove_child(self)
	player.gliding_system.glider_mount.add_child(self)
	self.name = "glider"
	player.gliding_system.glider = self
	Signals.enter_glider.emit()	
	player.state = player.State.GLIDING

func interact_action_held():
	Signals.open_wheel.emit(actions)
	
func on_wheel_selection(player: Player, selection: ItemAction):
	var ctx = {"player":player,
				"object":self,
				}
	selection.execute(ctx)
