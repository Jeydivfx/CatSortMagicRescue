extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.change_language("fa")
	assert(scene.L.t("Level 41")=="مرحله 41")
	assert(scene.EnvironmentCatalog.WORLDS.size()==6)
	for i in range(6):
		scene.environment_override = i
		scene.start_game(40)
		assert(scene.environment_index==i and scene.backdrop!=null)
		assert(is_equal_approx(scene.progress_label.position.x+scene.progress_label.size.x/2,360))
	var seen := {}
	var last := -1
	for gentle in [false,true]:
		scene.reduced_motion = gentle
		for i in range(12):
			scene.begin_witch_entry()
			assert(scene.entry_variant!=last)
			last = scene.entry_variant
			seen[last] = true
			assert(scene.entering and scene.wizard.entry_flying)
			await create_timer(.03).timeout
		assert(seen.size()==3)
		await create_timer(2).timeout
		assert(not scene.entering and not scene.wizard.entry_flying)
		assert(scene.wizard.position.is_equal_approx(Vector2(8,scene.wizard_home_y())))
		assert(scene.wizard.scale.is_equal_approx(Vector2.ONE))
	scene.free()
	print("PASS six worlds, Persian spelling, centered location, randomized nonrepeating entries in both motion modes")
	quit()
