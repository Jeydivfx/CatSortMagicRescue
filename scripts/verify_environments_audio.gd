extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var catalog = load("res://scripts/environment_catalog.gd")
	for pair in [[0,0],[99,0],[100,1],[199,1],[200,2],[299,2],[300,0],[999,0]]:
		assert(catalog.for_level(pair[0]) == pair[1])
	assert(catalog.for_level(0,2)==2)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.environment_override = -1
	scene.audio.set_music_enabled(false)
	for index in [0,100,200]:
		scene.start_game(index)
		assert(scene.environment_index == index/100)
		assert(scene.backdrop.get_width()>700 and scene.backdrop.get_height()>1200)
		assert(scene.progress_label.text == catalog.WORLDS[index/100].name)
	var cues: Array[String] = []
	scene.audio.set_enabled(true)
	scene.audio.cue_played.connect(func(name: String): cues.append(name))
	scene.load_level(0)
	scene.tubes = [[0,1,1],[1],[0,0],[],[]]
	await scene.transfer(0,1)
	assert(cues.filter(func(cue): return cue.begins_with("jump_")).size()==1)
	assert(not cues.has("cat"), "Incomplete tube must not meow")
	cues.clear()
	scene.tubes = [[0,1],[1,1,1],[0,0],[],[]]
	await scene.transfer(0,1)
	assert(cues.count("cat")==1,"Fourth matching cat must trigger one meow")
	cues.clear()
	scene.tubes = [[0,1,1,1],[1],[0,0],[],[]]
	scene.begin_drag(0,scene.cat_position(0,3))
	assert(not cues.has("cat"))
	scene.finish_drag(1)
	while scene.busy:
		await process_frame
	assert(cues.count("cat")==1)
	assert(cues.filter(func(cue): return cue.begins_with("jump_")).size()==1,"Drag should play only one jump sound")
	print("PASS three worlds, 100-level boundaries, manual override, jump on movement and one meow only on four-cat completion")
	scene.audio.set_enabled(false)
	await create_timer(0.25).timeout
	scene.free()
	await process_frame
	quit()
