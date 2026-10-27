extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	for dimensions in [Vector2i(540,840),Vector2i(540,1200)]:
		root.size = dimensions
		await process_frame
		scene.fit_mobile_screen()
		scene.start_game(0)
		await scene.transfer(0,2)
		await scene.transfer(1,0)
		await scene.transfer(2,1)
		await create_timer(1.2).timeout
		assert(not scene.ui.visible)
		var panel = scene.win_ui
		var controls: Array = [panel.move_label,panel.score_label,panel.reward_label,panel.next_button,panel.home_button]
		for i in range(controls.size()):
			for j in range(i+1,controls.size()):
				assert(not controls[i].get_global_rect().intersects(controls[j].get_global_rect()))
		assert(panel.card.get_global_rect().encloses(panel.score_label.get_global_rect()))
		assert(panel.card.get_global_rect().encloses(panel.reward_label.get_global_rect()))
		panel.next_pressed.emit()
		assert(scene.ui.visible and scene.level_index==1)
	scene.show_menu("credits")
	assert(scene.screen == "credits")
	var found := false
	for item in scene.menu_ui.get_children():
		if item is Label and item.text.contains("Kevin MacLeod"):
			found = true
	assert(found)
	print("PASS short/tall victory layout, score inside card, separate Home, hidden HUD, restored next level and visible attribution")
	scene.free()
	quit()
