extends Node


const DEBUG := true

enum DebugChannel {
	BUILDING,
	CAMERA,
	CRAFTING,
	PHYSICS,
	PLAYER,
}

var debug_channels := {
	DebugChannel.BUILDING: false,
	DebugChannel.CAMERA: false,
	DebugChannel.CRAFTING: false,
	DebugChannel.PHYSICS: true,
	DebugChannel.PLAYER: true,
}

func dprint(channel: DebugChannel, msg: String) -> void:
	if DEBUG and debug_channels.get(channel, false):
		print("[%s] %s" % [DebugChannel.keys()[channel], msg])
