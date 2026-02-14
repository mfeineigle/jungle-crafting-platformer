extends ItemAction
class_name ReclaimItemAction


func execute(ctx):
	var player = ctx["player"]
	var object = ctx["object"]
	for item in load(object.item_path).inputs:
		player.add_to_inventory(item)
	if "segments" in object.get_parent():
		for seg in object.get_parent().segments:
			seg.queue_free()
	object.queue_free()
	player.state = player.State.NORMAL
