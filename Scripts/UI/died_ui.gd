extends Control

var is_dead: bool = false
@onready var reload_checkpoint: Button = $Panel/VBoxContainer/VBoxContainer/reload_checkpoint
@onready var reload_level: Button = $Panel/VBoxContainer/VBoxContainer/reload_level
@onready var quit: Button = $Panel/VBoxContainer/VBoxContainer/quit

func _ready() -> void:
	visible = false
	Signals.player_died.connect(_player_died)
	process_mode = Node.PROCESS_MODE_ALWAYS
	reload_checkpoint.pressed.connect(_on_reload_checkpoint_pressed)
	reload_level.pressed.connect(_on_reload_level_pressed)
	quit.pressed.connect(_on_quit_pressed)
	Signals.checkpoints_cleared.connect(_on_checkpoints_cleared)
	Signals.checkpoint_activated.connect(_on_checkpoint_activated)


	
func _player_died() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	player.is_dead = true
	visible = true
	Signals.camera_toggled.emit(player.is_dead)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
func _on_checkpoints_cleared() -> void:
	reload_checkpoint.disabled = true

func _on_checkpoint_activated() -> void:
	reload_checkpoint.disabled = false
	
func _on_reload_checkpoint_pressed() -> void:
	get_tree().paused = false
	var player = get_tree().get_first_node_in_group("player") as Player
	Signals.reload_checkpoint.emit(player)
	visible = false
	player.is_dead = false
	Signals.camera_toggled.emit(is_dead)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_reload_level_pressed() -> void:
	get_tree().paused = false
	visible = false
	Signals.camera_toggled.emit(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Free the old player before reloading so take_player spawns fresh
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.queue_free()
	SceneManager.reload_current_scene()
	
func _on_quit_pressed() -> void:
	get_tree().quit()
	
	
