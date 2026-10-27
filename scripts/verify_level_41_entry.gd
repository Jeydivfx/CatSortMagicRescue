extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.story_progress.intro_seen = true
	scene.story_progress.worlds = ["0","1","2","3","4","5"]
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(false)
	scene.reduced_motion = true
	scene.unlocked = maxi(42,scene.unlocked)
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	assert(scene.open_map_level(40))
	assert(scene.level_index==40 and scene.wizard.entry_flying and scene.entering)
	await create_timer(.4).timeout
	assert(scene.wizard.entry_flying and cues.has(scene.audio.ENTRY_CUES[scene.entry_variant]))
	await create_timer(.9).timeout
	assert(not scene.entering and not scene.wizard.entry_flying)
	scene.show_menu("pause")
	for node in scene.menu_ui.get_children():
		if node is Button and node.text==scene.L.t("Restart level"): node.pressed.emit()
	assert(scene.level_index==40 and scene.entering and scene.wizard.entry_flying)
	await create_timer(1.3).timeout
	scene.next_level()
	assert(scene.level_index==41 and scene.entering and scene.wizard.entry_flying)
	scene.cancel_witch_entry()
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS level 41 with saved gentle setting: broom and laugh via map, restart and next level")
	quit()
