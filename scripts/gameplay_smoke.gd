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
		_fail("Could not instantiate the gameplay scene")
		return

	root.add_child(instance)
	await process_frame
	var initial_state: Dictionary = instance.call("_mcp_state")
	var collect_method_present := instance.has_method("collect_target")
	var collected_score := int(instance.call("collect_target")) if collect_method_present else 0
	await process_frame
	var final_state: Dictionary = instance.call("_mcp_state")
	var gameplay_ok: bool = collect_method_present and collected_score == 1 and bool(final_state.get("game_won", false)) and bool(final_state.get("target_collected", false))
	print("QA_GAMEPLAY_STATE_API=%s" % initial_state.has("score"))
	print("QA_COLLECT_TARGET=%s" % gameplay_ok)
	print("QA_GAMEPLAY_SCORE=%s" % final_state.get("score", -1))
	instance.queue_free()
	quit(0 if gameplay_ok else 1)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
