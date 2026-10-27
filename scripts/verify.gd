extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	assert(scene.levels.size() == 1000)
	assert(scene.screen == "menu" and not scene.cat_layer.visible)
	scene.show_menu("levels")
	assert(scene.screen == "levels")
	scene.show_menu("settings")
	assert(scene.screen == "settings")
	scene.start_game(0)
	assert(scene.screen == "game" and scene.cat_layer.visible)
	scene.update_actors()
	var actor = scene.actors[0]
	actor.animate(0.0, false, 0.0, 2)
	assert(actor.face == 2)
	actor.animate(0.0, false, 0.0, 3)
	assert(actor.face == 3)
	var blink_time: float = .075-actor.phase*1.71
	actor.animate(blink_time, false)
	assert(actor.face_weights.y>.99)
	actor.animate(1.0, false)
	assert(actor.face == 0)
	var stable_region: Rect2 = actor.sprite.region_rect
	for expression in range(4):
		actor.animate(2.0 + expression / 60.0, false, 0.0, expression)
		assert(actor.sprite.region_rect == stable_region, "Expressions must preserve the original body geometry")
	var voice_profiles := {}
	for cat_kind in range(11):
		var first_voice: Dictionary = scene.audio.choose_cat_voice(cat_kind)
		var second_voice: Dictionary = scene.audio.choose_cat_voice(cat_kind)
		assert(first_voice["source"] != second_voice["source"])
		assert(scene.audio.sounds.has(first_voice["source"]))
		voice_profiles[str(first_voice)] = true
	assert(voice_profiles.size() == 11)
	print("PASS fixed body geometry and eleven alternating voice profiles")
	print("PASS home, level selection, settings, play and four facial states")
	for index in range(scene.levels.size()):
		scene.load_level(index)
		var counts := {}
		for tube in scene.tubes:
			assert(tube.size() <= 4)
			for cat in tube:
				counts[cat] = counts.get(cat, 0) + 1
		for count in counts.values():
			assert(count == 4)
		var steps := 0
		while not scene.solved(scene.tubes) and steps < 70:
			await scene.show_hint()
			assert(scene.hint_pair.size() == 2, "No solution at level %d" % (index + 1))
			var src: int = scene.hint_pair[0]
			var dst: int = scene.hint_pair[1]
			assert(scene.legal(scene.tubes, src, dst))
			scene.tubes[dst].append(scene.tubes[src].pop_back())
			scene.hint_pair.clear()
			steps += 1
		assert(scene.solved(scene.tubes))
		print("PASS level %d: %d legal single-cat moves" % [index + 1, steps])
	scene.load_level(0)
	var initial: Array = scene.tubes.duplicate(true)
	await scene.transfer(0, 2)
	assert(scene.moves == 1)
	scene.update_actors()
	assert(scene.actors.size() == 8 and scene.flying == -1)
	var surviving = scene.actors[0]
	await scene.transfer(1, 0)
	assert(is_instance_valid(surviving), "Unmoved cats must retain their animation state")
	scene.undo()
	scene.undo()
	assert(scene.tubes == initial and scene.moves == 0)
	var balance_before_hint: int = scene.wallet.coins
	await scene.request_hint()
	assert(scene.hint_used)
	assert(scene.wallet.coins == balance_before_hint-scene.wallet.hint_price(0))
	var original_hint: Array = scene.hint_pair.duplicate()
	await scene.request_hint()
	assert(scene.hint_pair == original_hint)
	assert(scene.wallet.coins == balance_before_hint-scene.wallet.hint_price(0))
	scene.request_extra_tube()
	assert(scene.pending_reward >= 0 and scene.tubes.size() == initial.size())
	var cancelled_id: int = scene.pending_reward
	scene.cancel_reward()
	assert(scene.tubes.size() == initial.size() and scene.pending_reward == -1)
	scene.ads.finish_reward(cancelled_id, scene.ads.Result.COMPLETED)
	assert(scene.tubes.size() == initial.size(), "Stale callbacks must not grant a tube")
	scene.request_extra_tube()
	await create_timer(3.2).timeout
	var earned_id: int = scene.pending_reward
	scene.complete_preview_reward()
	assert(scene.tubes.size() == initial.size() + 1)
	scene.ads.finish_reward(earned_id, scene.ads.Result.COMPLETED)
	scene.request_extra_tube()
	assert(scene.tubes.size() == initial.size() + 1)
	assert(scene.get_banner_rect().position.y >= scene.tube_rect(0).end.y)
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	assert(not scene.audio.music.playing)
	assert(scene.audio.sounds.has("kitten_3"))
	scene.level_page = 99
	scene.show_menu("levels")
	assert(scene.screen == "levels" and scene.level_page == 99)
	scene.start_game(999)
	scene.update_actors()
	assert(scene.tubes.size() <= 14 and scene.actors.size() == 36)
	for rendered_cat in scene.actors:
		assert(rendered_cat.kind < 12)
		assert(rendered_cat.position.x > 0 and rendered_cat.position.x < 720)
	scene.load_level(0)
	print("PASS persistent actors, undo, paid hint without duplicate charge, cancelled/completed/duplicate rewards, banner and audio mute")
	scene.load_level(0)
	await scene.transfer(0, 2)
	await scene.transfer(1, 0)
	await scene.transfer(2, 1)
	assert(scene.won and is_instance_valid(scene.win_ui))
	assert(int(scene.best_moves["0"]) <= 3)
	await create_timer(1.35).timeout
	assert(scene.win_ui.cue_history == ["win", "star_0", "star_1", "star_2"])
	assert(scene.win_ui.move_label.text == scene.L.t("Moves: 3"))
	assert(not scene.win_ui.next_button.disabled)
	assert(scene.audio.sounds.has("star_2"))
	assert(is_instance_valid(scene.win_ui.cat.victory_mesh))
	var celebration_position: Vector2 = scene.win_ui.cat.position
	scene.win_ui.cat.animate_victory(4.0, false)
	assert(scene.win_ui.cat.position != celebration_position)
	scene.win_ui.next_pressed.emit()
	assert(scene.level_index == 1 and not scene.won and not is_instance_valid(scene.win_ui))
	print("PASS animated level complete, best moves and next-level navigation")
	scene.load_level(0)
	scene.tubes = [[0,1,1],[1,1],[0,0,0],[],[]]
	scene.update_actors()
	var before_group: Array = scene.tubes.duplicate(true)
	scene.begin_drag(0, scene.cat_position(0,2))
	assert(scene.drag_active and scene.drag_count == 2)
	scene.finish_drag(1)
	await scene.flight_tween.finished
	assert(scene.tubes[0] == [0] and scene.tubes[1] == [1,1,1,1])
	assert(scene.moves == 1 and scene.flight_cats.is_empty())
	scene.undo()
	assert(scene.tubes == before_group and scene.moves == 0)
	scene.tubes = [[0,1,1,1],[1],[0,0,0],[],[]]
	await scene.transfer(0, 1, 3)
	assert(scene.tubes[1].size() == 4 and scene.tubes[0] == [0])
	scene.undo()
	scene.tubes = [[1,1],[1,1,1],[0,0,0,0],[]]
	await scene.transfer(0,1,2)
	assert(scene.tubes[0] == [1] and scene.tubes[1].size() == 4)
	scene.undo()
	var invalid_before: Array = scene.tubes.duplicate(true)
	scene.begin_drag(0, scene.cat_position(0,1))
	scene.finish_drag(2)
	assert(not scene.drag_active and scene.tubes == invalid_before)
	scene.begin_drag(0, scene.cat_position(0,1))
	scene.cancel_drag()
	assert(scene.tubes == invalid_before and not scene.drag_active)
	print("PASS two/three-cat drag, capacity limit, invalid drop, cancel and grouped Undo")
	scene.free()
	await process_frame
	quit()
