extends Node

signal scene_loaded(scene: Node)

var _is_loading := false
var _queue: Array[PackedScene] = []
var _current_scene: PackedScene
var _current_path: String
var _progress := []


func load_scene(scene: PackedScene) -> void:
	if scene == null:
		push_error("SceneManager.load_scene called with null PackedScene")
		return
	_queue.append(scene)
	_try_load_next()

func _try_load_next() -> void:
	if _is_loading or _queue.is_empty():
		return
	_current_scene = _queue.pop_front()
	_current_path = _current_scene.resource_path
	#_current_path = _queue.pop_front()
	if _current_path.is_empty():
		push_error("PackedScene has no resource_path (runtime-created scene?)")
		return
	_progress.clear()
	_is_loading = true
	ResourceLoader.load_threaded_request(_current_path)

func _process(_delta: float) -> void:
	if not _is_loading:
		return
	var status := ResourceLoader.load_threaded_get_status(_current_path, _progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed := ResourceLoader.load_threaded_get(_current_path) as PackedScene
		var instance := packed.instantiate()
		_is_loading = false
		scene_loaded.emit(instance)
		_try_load_next()
