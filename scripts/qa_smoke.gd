extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene: PackedScene = load("res://scenes/main.tscn")
	if packed_scene == null:
		_fail("Could not load res://scenes/main.tscn")
		return

	var instance := packed_scene.instantiate()
	if instance == null:
		_fail("Could not instantiate the main scene")
		return

	root.add_child(instance)
	await process_frame
	var has_state_api := instance.has_method("_mcp_state")
	var bridge_present := get_root().has_node("MCPRuntimeBridge")
	print("QA_SCENE_LOADED=true")
	print("QA_MCP_STATE_API=%s" % has_state_api)
	print("QA_RUNTIME_BRIDGE_AUTOLOAD=%s" % bridge_present)
	instance.queue_free()
	quit(0 if has_state_api and bridge_present else 1)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
