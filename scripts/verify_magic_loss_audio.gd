extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(false)
	scene.start_game(0)
	assert(scene.audio.sounds.witch_laugh_loss.get_length()>4.2)
	assert(scene.audio.sounds.witch_laugh.get_length()<2)
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	scene.tubes = [[0,0],[1,0,1,0],[],[1,1]]
	scene.moves = scene.move_limit()-1
	await scene.transfer(0,2)
	assert(scene.lost and cues.count("witch_laugh_loss")==1)
	var before: String = str(scene.tubes)
	await create_timer(2.3).timeout
	var playing := false
	for voice in scene.audio.voices:
		if voice.get_meta("cue_name","")=="witch_laugh_loss" and voice.playing: playing = true
	assert(playing and not scene.wizard.spells.is_empty())
	for i in range(10): scene.wizard.throw_magic(1)
	assert(scene.wizard.spells.size()<=4 and str(scene.tubes)==before)
	scene.undo()
	assert(not scene.lost and scene.wizard.spells.is_empty())
	for voice in scene.audio.voices:
		if voice.get_meta("cue_name","")=="witch_laugh_loss": assert(not voice.playing)
	scene.audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	print("PASS 4.4-second loss laugh, short idle laugh, sustained loss playback, bounded visual-only magic and clean Undo recovery")
	quit()
