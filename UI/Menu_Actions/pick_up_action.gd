extends ItemAction
class_name PickUpAction

func execute(ctx):
	var player = ctx["player"]
	var object = ctx["object"]
	player.add_to_inventory(load(object.item_path))
	if "segments" in object.get_parent():
		for seg in object.get_parent().segments:
			seg.queue_free()
	object.queue_free()
	player.set_state(player.State.NORMAL)
