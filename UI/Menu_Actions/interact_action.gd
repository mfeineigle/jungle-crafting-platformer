extends ItemAction
class_name UseItemAction


func execute(ctx):
	var player = ctx["player"]
	var object = ctx["object"]
	object.interact_action(player)
