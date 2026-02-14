extends CanvasLayer

@onready var selection_wheel: Control = $selection_wheel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selection_wheel.hide()
	Signals.open_wheel.connect(open_wheel)
	Signals.close_wheel.connect(close_wheel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# NOTE can be removed, only for testing
	if Input.is_action_just_pressed("selection_wheel") and not selection_wheel.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Signals.camera_toggled.emit(true)
		selection_wheel.show()
	elif Input.is_action_just_pressed("selection_wheel") and selection_wheel.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Signals.camera_toggled.emit(false)
		selection_wheel.hide()

func open_wheel(interactable_actions) -> void:
	selection_wheel.options = interactable_actions
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Signals.camera_toggled.emit(true)
	selection_wheel.show()

func close_wheel() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Signals.camera_toggled.emit(false)
	selection_wheel.hide()
	if selection_wheel.options[selection_wheel.selection]:
		Signals.wheel_selection_made.emit(selection_wheel.options[selection_wheel.selection])
