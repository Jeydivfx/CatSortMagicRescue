extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_music_enabled(false)
	scene.audio.set_enabled(true)
	scene.start_game(0)
	assert(is_equal_approx(scene.status.position.x+scene.status.size.x/2,360))
	assert(is_equal_approx(scene.rescued_label.position.x+scene.rescued_label.size.x/2,360))
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	assert(not cues.has("witch_upset"))
	await scene.transfer(2,1)
	assert(scene.wizard.defeated and scene.wizard.impact_played)
	assert(cues.count("witch_upset")==1 and cues.count("staff_thud")==2)
	assert(cues.find("spell_break")<=cues.find("witch_upset"))
	assert(cues.find("witch_upset")<cues.rfind("staff_thud"))
	scene.start_game(0)
	assert(not scene.wizard.defeated and not scene.wizard.impact_played)
	for dimensions in [Vector2i(540,840),Vector2i(540,1200)]:
		root.size = dimensions
		await process_frame
		for page in ["menu","settings"]:
			scene.show_menu(page)
			var controls: Array = []
			for item in scene.menu_ui.get_children():
				if item is Button or item is HSlider:
					for previous in controls: assert(not item.get_rect().intersects(previous))
					controls.append(item.get_rect())
			assert(controls.size()>=3)
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS centered footer, timed defeat voice and single staff impact, reset, home/settings non-overlapping controls")
	quit()
