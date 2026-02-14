extends CanvasLayer

const SLOT_COUNT := 30
var inventory_menu_open: bool = false
var crafted_something: bool = false

# preload map of which item "teaches" which recipe
var recipe_discovery: Dictionary = {
	"vine": preload("res://Items/Resources/rope.tres"),
	"stick": preload("res://Items/Resources/ladder.tres"),
	"leaf": preload("res://Items/Resources/glider.tres"),
}

var known_recipes: Dictionary = {
	#"vine": preload("res://Items/Resources/rope.tres"),
	#"stick": preload("res://Items/Resources/ladder.tres"),
	#"leaf": preload("res://Items/Resources/glider.tres"),
}

@onready var popup_panel: PopupPanel = $PopupPanel
@onready var popup_label: Label = $PopupPanel/popup_label

@onready var inventory_close_btn: Button = $Control/HBoxContainer/InventoryCenterContainer/PanelContainer/MarginContainer/VBoxContainer/inventory_header/inventory_close_btn
@onready var inventory_list: GridContainer = $Control/HBoxContainer/InventoryCenterContainer/PanelContainer/MarginContainer/VBoxContainer/inventory_list

@onready var recipe_close_btn: Button = $Control/HBoxContainer/RecipeCenterContainer/PanelContainer/MarginContainer/VBoxContainer/recipe_header/recipe_close_btn
@onready var recipe_list: VBoxContainer = $Control/HBoxContainer/RecipeCenterContainer/PanelContainer/MarginContainer/VBoxContainer/recipe_list


func _ready() -> void:
	visible = false
	Signals.inventory_changed.connect(_update_inventory_grid)
	Signals.toggle_inventory_menu.connect(_toggle_inventory_menu)
	Signals.learned_recipe.connect(_learn_recipe)
	_build_inventory_slots()
	#_update_inventory_grid(player.inventory)
	inventory_close_btn.pressed.connect(_toggle_inventory_menu)
	recipe_close_btn.pressed.connect(_toggle_inventory_menu)


func _build_inventory_slots():
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
		inventory_list.add_child(slot)


func _update_inventory_grid(inventory_items: Array):
	var slots := inventory_list.get_children()
	for i in slots.size():
		var icon := slots[i].get_node("Icon") as TextureRect
		if i < inventory_items.size():
			var item = inventory_items[i]
			if item is Item:
				icon.texture = item.icon
			elif item is String:
				icon.texture = load(item).icon
			icon.visible = true
		else:
			icon.texture = null
			icon.visible = false
	_update_recipes()



func _update_recipes():
	_clear_recipes()
	var max_inputs := _get_max_recipe_inputs()
	for recipe in known_recipes.values(): #CHANGE
		# Build a row per recipe
		var row_panel := PanelContainer.new()
		row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Visual row separation
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = Color(0.12, 0.12, 0.12)
		row_style.border_width_bottom = 1
		row_style.border_color = Color(0.25, 0.25, 0.25)
		row_panel.add_theme_stylebox_override("panel", row_style)
		var row := HBoxContainer.new()
		row_panel.add_child(row)
		# update ingredient inputs
		var input_box := HBoxContainer.new()
		input_box.add_theme_constant_override("separation", 4)
		row.add_child(input_box)
		for ingredient in recipe.inputs:
			var slot := PanelContainer.new()
			slot.custom_minimum_size = Vector2(64, 64)
			slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var slot_style := StyleBoxFlat.new()
			slot_style.border_width_left = 2
			slot_style.border_width_right = 2
			slot_style.border_width_top = 2
			slot_style.border_width_bottom = 2
			slot_style.border_color = Color(0.3, 0.3, 0.3)
			slot_style.bg_color = Color(0.1, 0.1, 0.1)
			slot.add_theme_stylebox_override("panel", slot_style)
			var icon := TextureRect.new()
			icon.texture = ingredient.icon
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
			if not _is_craftable(recipe, true):
				icon.modulate = Color(0.5, 0.5, 0.5)
			slot.add_child(icon)
			input_box.add_child(slot)
		# fill in blank inputs
		var missing: int = max_inputs - recipe.inputs.size()
		for i in missing:
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(64, 64)
			spacer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			input_box.add_child(spacer)
		# final blank spacer
		var flex := Control.new()
		flex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		input_box.add_child(flex)
		
		# Arrow or separator
		var arrow := Label.new()
		arrow.text = "→"
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(arrow)
		
		# Output icon inside button
		var output_btn = Button.new()
		#output_btn.size_flags_horizontal = Control.SIZE_FILL
		output_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		output_btn.custom_minimum_size = Vector2(64, 64)  # same as icon
		var output_icon = TextureRect.new()
		output_icon.texture = recipe.icon
		if _is_craftable(recipe, true):
			output_icon.modulate = Color.WHITE
		else:
			output_icon.modulate = Color(0.5, 0.5, 0.5)
		output_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		output_icon.custom_minimum_size = Vector2(64, 64)
		output_btn.add_child(output_icon)
		# Connect button press to crafting
		output_btn.pressed.connect(func(): _craft_recipe(recipe))
		# Add the row to the panel
		row.add_child(output_btn)
		recipe_list.add_child(row_panel)
		
func  _clear_recipes() -> void:
	if recipe_list.get_child_count() > 0:
		for node in recipe_list.get_children():
			node.queue_free()

func _learn_recipe(item: Item) -> void:
	# Check if you know the recipe associated with item
	if known_recipes.has(item.id):
		return
	# If not, learn it
	known_recipes[item.id] = _get_recipe_discovery(item)
	Signals.msg_sent.emit(item.recipe_msg)
	_update_recipes()
	if known_recipes.size() == 1:
		Signals.msg_sent.emit("Craft a vine. Press 'i' to view your new recipe.")
		

## Lookup which recipe is learned via item
func _get_recipe_discovery(item):
	return recipe_discovery[item.id]

func _get_max_recipe_inputs() -> int:
	var max_inputs := 0
	for recipe in known_recipes.values():
		max_inputs = max(max_inputs, recipe.inputs.size())
	return max_inputs
			
## Build a dictionary to count how many of each ingredient is required
func _is_craftable(recipe: Item, recipe_check: bool) -> bool:
	var required_counts = {}
	for ingredient in recipe.inputs:
		if required_counts.has(ingredient):
			required_counts[ingredient] += 1
		else:
			required_counts[ingredient] = 1
	# Check if player has enough of each ingredient
	for ingredient in required_counts.keys():
		var needed = required_counts[ingredient]
		var player = get_tree().get_first_node_in_group("player")
		if player.inventory.count(ingredient) < needed:
			if not recipe_check: #only msg on actual crafting
				var msg: String = "Not enough " + ingredient.display_name + "s"
				Globals.dprint(Globals.DebugChannel.CRAFTING, msg)
				Signals.msg_sent.emit(msg)
			return false
	return true

func _craft_recipe(recipe: Item):
	if not crafted_something:
		Signals.msg_sent.emit("Press 'c' to build your "+recipe.display_name)
	if _is_craftable(recipe, false):
		crafted_something = true
		Signals.craft_remove.emit(recipe.inputs)
		Signals.craft_add.emit([recipe])
		Signals.msg_sent.emit("Crafted: "+recipe.display_name)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel"):
		if visible:
			_toggle_inventory_menu()
			
func _toggle_inventory_menu() -> void:
	inventory_menu_open = !inventory_menu_open
	Signals.camera_toggled.emit(inventory_menu_open)
	if inventory_menu_open:
		_open()
	else:
		_close()

func _open():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _close():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
