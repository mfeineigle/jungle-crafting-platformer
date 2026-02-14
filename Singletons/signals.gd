extends Node

# Inventory signals
@warning_ignore_start("unused_signal")
signal camera_toggled(is_open)
signal inventory_changed(inventory)
signal craft_remove(items: Array)
signal craft_add(items: Array)
signal spawn_ghost_block(item: Item)
signal toggle_build_menu
signal toggle_inventory_menu
signal close_build_menu
signal enter_glider
signal open_wheel(interactable_actions: Array)
signal close_wheel
signal wheel_selection_made(player: Node3D, selection: String)
signal msg_sent(msg: String)
signal learned_recipe(recipe: String)
signal open_lvl_select
signal loaded_level
signal trap_triggered(trap)
