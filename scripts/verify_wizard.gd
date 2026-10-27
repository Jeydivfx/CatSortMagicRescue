extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	for dimensions in [Vector2i(540,840),Vector2i(540,1200)]:
		root.size = dimensions
		await process_frame
		scene.fit_mobile_screen()
		for index in [0,100,999]:
			scene.start_game(index)
			var bounds: Rect2 = scene.wizard.get_rect()
			for tube in range(scene.tubes.size()):
				assert(not bounds.intersects(scene.tube_rect(tube)))
			for button in [scene.undo_button,scene.hint_button,scene.tube_button]:
				assert(not bounds.intersects(button.get_rect()))
			assert(not bounds.intersects(scene.get_banner_rect()))
	scene.start_game(0)
	assert(scene.wizard.cast_count==0)
	await scene.transfer(0,2)
	assert(scene.wizard.cast_count==0)
	await scene.transfer(1,0)
	assert(scene.wizard.cast_count==0 and not scene.wizard.angry)
	assert(scene.rescued_label.text.contains("1 / 2"))
	scene.undo()
	assert(scene.rescued_label.text.contains("0 / 2"))
	scene.load_level(0)
	assert(scene.wizard.cast_count==0)
	scene.show_menu()
	assert(not scene.wizard.is_visible_in_tree())
	print("PASS witch never frees individual groups, accurate spell count with Undo, reset, menu visibility and mobile layout")
	scene.free()
	quit()
