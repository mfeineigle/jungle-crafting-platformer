extends PanelContainer

var _timer: SceneTreeTimer

func start(duration: float) -> void:
	_timer = get_tree().create_timer(duration)
	_wait()

func _wait() -> void:
	while true:
		if _timer.time_left == 0.0:
			close()
			return
		await get_tree().process_frame

func close() -> void:
	queue_free()
