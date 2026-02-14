extends CanvasLayer

const SLOT_COUNT := 10
var build_menu_open: bool = false

@onready var build_menu: GridContainer = %buildMenu
@onready var build_close_button: Button = %build_close_button
@onready var popup_panel: PopupPanel = $PopupPanel
@onready var popup_label: Label = $PopupPanel/popupLabel

@onready  var buildable_items: Array[Item] = [preload("res://Items/Resources/glider.tres"),
												preload("res://Items/Resources/ladder.tres"),
												preload("res://Items/Resources/rope.tres"),
											]

func _ready() -> void:
	visible = false
	Signals.toggle_build_menu.connect(_toggle_build_menu)
	build_close_button.pressed.connect(_toggle_build_menu)
	_build_blank_slots()
	_populate_build_menu()


func _build_blank_slots():
	for i in SLOT_COUNT:
		var slot := PanelContainer.new()
		# --- slot sizing ---
		slot.custom_minimum_size = Vector2(64, 64)
		# --- border ---
		var style := StyleBoxFlat.new()
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.3, 0.3)
		style.bg_color = Color(0.1, 0.1, 0.1)
		slot.add_theme_stylebox_override("panel", style)
		# --- icon ---
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		# add slots
		slot.add_child(icon)
		build_menu.add_child(slot)

func _populate_build_menu():
	var slots := build_menu.get_children()
	for i in slots.size():
		var slot = slots[i] as PanelContainer
		var icon = slot.get_node("Icon") as TextureRect
		# Remove any previous buttons inside the slot (if you added dynamically before)
		for child in slot.get_children():
			if child != icon:
				child.queue_free()
		if i < buildable_items.size():
			var item = buildable_items[i]
			var in_inventory = _is_in_inventory(item)
			icon.texture = item.icon
			icon.visible = true
			# Create button inside slot, separate from the icon
			var btn = Button.new()
			#btn.size_flags_horizontal = Control.SIZE_FILL
			#btn.size_flags_vertical = Control.SIZE_FILL
			#btn.custom_minimum_size = Vector2(64,64)
			slot.add_child(btn)
			# Put a new icon inside the button (don't reuse the old one)
			var btn_icon = TextureRect.new()
			btn_icon.texture = item.icon
			btn_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			# Gray out if not in inventory
			btn_icon.modulate = Color(1,1,1) if in_inventory else Color(0.5,0.5,0.5)
			btn.add_child(btn_icon)
			btn.pressed.connect(_try_to_build.bind(item))

func _try_to_build(item: Item) -> void:
	if _is_in_inventory(item):
		Signals.spawn_ghost_block.emit(item)
		Signals.toggle_build_menu.emit()
	else:
		var msg: String = "Missing " + item.display_name
		Globals.dprint(Globals.DebugChannel.BUILDING, msg)
		Signals.msg_sent.emit(msg)
		
func _is_in_inventory(buildable) -> bool:
	var player = get_tree().get_first_node_in_group("player")
	return buildable in player.inventory


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel"):
		if visible:
			_toggle_build_menu()

func _toggle_build_menu() -> void:
	build_menu_open = !build_menu_open
	Signals.camera_toggled.emit(build_menu_open)
	if build_menu_open:
		open()
	else:
		close()
		
func open():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_populate_build_menu()

func close():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
