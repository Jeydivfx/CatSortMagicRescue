extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.start_game(0)
	scene.tubes = [[0,1,1],[1,1],[0,0,0],[],[]]
	await process_frame
	var source: Vector2 = scene.get_global_transform_with_canvas()*scene.cat_position(0,2)
	var target: Vector2 = scene.get_global_transform_with_canvas()*scene.cat_position(1,2)
	var move := InputEventMouseMotion.new()
	move.position = source
	move.global_position = source
	root.push_input(move, true)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = source
	press.global_position = source
	root.push_input(press, true)
	await process_frame
	if scene.pointer_source != 0:
		push_error("Pointer press did not capture its source tube")
		quit(1)
		return
	move = InputEventMouseMotion.new()
	move.position = target
	move.global_position = target
	move.button_mask = MOUSE_BUTTON_MASK_LEFT
	move.relative = target-source
	root.push_input(move, true)
	await process_frame
	assert(scene.drag_active and scene.drag_count == 2)
	press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = false
	press.position = target
	press.global_position = target
	root.push_input(press, true)
	await process_frame
	while scene.busy:
		await process_frame
	assert(scene.tubes[0] == [0] and scene.tubes[1] == [1,1,1,1] and scene.moves == 1)
	print("PASS actual pointer press, drag threshold, release and grouped transfer")
	for count in [3,4]:
		scene.load_level(0)
		scene.tubes = [[],[],[0,0,0,0],[2],[]]
		for i in range(count):
			scene.tubes[0].append(1)
		scene.update_actors()
		await process_frame
		source = scene.get_global_transform_with_canvas()*scene.cat_position(0,count-1)
		target = scene.get_global_transform_with_canvas()*scene.cat_position(1,0)
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.pressed = true
		touch.position = source
		root.push_input(touch,true)
		var touch_move := InputEventScreenDrag.new()
		touch_move.index = 0
		touch_move.position = target
		root.push_input(touch_move,true)
		assert(scene.drag_active and scene.drag_count == count)
		touch = InputEventScreenTouch.new()
		touch.index = 0
		touch.position = target
		root.push_input(touch,true)
		while scene.busy:
			await process_frame
		assert(scene.tubes[0].is_empty() and scene.tubes[1].size() == count and scene.moves == 1)
		scene.undo()
		assert(scene.tubes[0].size() == count and scene.tubes[1].is_empty())
	print("PASS native touch: three/four cats together, one move and one Undo")
	scene.load_level(0)
	scene.tubes = [[0,1,1,1],[1],[0,0,0],[2],[]]
	scene.choose(0)
	scene.choose(1)
	while scene.busy:
		await process_frame
	assert(scene.tubes[0] == [0] and scene.tubes[1] == [1,1,1,1])
	print("PASS tap-to-select also transfers the complete matching run")
	var recent: Array = []
	var used := {}
	for i in range(300):
		var choice: Dictionary = scene.audio.choose_cat_voice(i%11)
		assert(not recent.has(choice.source))
		assert(scene.audio.sounds.has(choice.source))
		used[choice.source] = true
		recent.append(choice.source)
		if recent.size() > 6:
			recent.pop_front()
	assert(used.size() == 17)
	print("PASS 17 recorded meows, 300 selections without repeating the last six")
	scene.free()
	await process_frame
	quit()
