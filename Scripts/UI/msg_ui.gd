extends Control

@onready var vbox: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer
@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer

@export var msg_scene: PackedScene

var msg_queue: Array[PanelContainer] = []

func _ready() -> void:
	panel_container.hide()
	Signals.msg_sent.connect(show_msg)

func show_msg(text: String) -> void:
	var duration: float = 5.0
	panel_container.show()
	var msg: PanelContainer = msg_scene.instantiate()
	vbox.add_child(msg)
	msg.get_node("Label").text = text
	msg_queue.append(msg)
	msg.start(duration)
	msg.tree_exited.connect(func():
		_remove_msg(msg)
	)

func _remove_msg(msg: PanelContainer) -> void:
	msg_queue.erase(msg)
	if msg_queue.is_empty():
		panel_container.hide()

func _input(event: InputEvent) -> void:
	if msg_queue.is_empty():
		return
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		msg_queue[0].close()
		get_viewport().set_input_as_handled()
		
		
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		msg_queue[0].close()
		accept_event()
	
