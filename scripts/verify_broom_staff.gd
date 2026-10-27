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
	scene.reduced_motion = false
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	scene.start_game(0,true)
	assert(scene.wizard.entry_flying and cues.count(scene.audio.ENTRY_CUES[scene.entry_variant])==1)
	await create_timer(.8).timeout
	assert(scene.entering and scene.wizard.entry_flying)
	assert((scene.wizard.laughter>.5)==(scene.entry_variant==0))
	await create_timer(1.15).timeout
	assert(not scene.entering and not scene.wizard.entry_flying)
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	await scene.transfer(2,1)
	assert(scene.wizard.is_staff_dropped())
	scene.wizard.defeat_age = 3
	assert(scene.wizard.is_staff_dropped())
	scene.start_game(0)
	assert(not scene.wizard.is_staff_dropped())
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS broom flight with evil laugh, landing unlock and staff remains dropped through results until next round")
	quit()
