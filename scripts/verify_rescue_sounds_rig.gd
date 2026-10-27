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
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	scene.hud.update_progress(1,3,2,2,4)
	await create_timer(.9).timeout
	assert(not cues.has("hud_star_1"))
	var witch = scene.wizard
	var initial: Vector2 = witch.head.position
	witch._process(.1)
	assert(witch.head.position!=initial and witch.head.get_parent()!=witch.body)
	witch.angry = true
	witch._process(.016)
	assert(witch.anger>0 and witch.anger<.2)
	witch.reset()
	await scene.transfer(0,2)
	await scene.transfer(1,0)
	assert(not cues.has("spell_break") and not cues.has("escape"))
	await scene.transfer(2,1)
	await create_timer(1).timeout
	assert(cues.count("spell_break")==1 and cues.count("escape")==1)
	assert(cues.find("spell_break")<cues.find("escape"))
	for index in range(1,4): assert(cues.count("hud_star_%d" % index)==1)
	for stars in [1,2]:
		cues.clear()
		scene.level_reward = {"score":100,"stars":stars,"coins":20}
		scene.show_win()
		await create_timer(1).timeout
		for index in range(1,4): assert(cues.count("hud_star_%d" % index)==(1 if index<=stars else 0))
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS articulated witch, eased expressions, quiet HUD, timed shatter/escape and earned-only result star sounds")
	quit()
