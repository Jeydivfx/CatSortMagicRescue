extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(false)
	var cues: Array = []
	scene.audio.cue_played.connect(func(cue): cues.append(cue))
	var seen := {}
	for gentle in [false,true]:
		scene.reduced_motion = gentle
		for i in range(15):
			cues.clear()
			scene.begin_witch_entry()
			var expected: String = scene.audio.ENTRY_CUES[scene.entry_variant]
			assert(cues==[expected])
			seen[expected] = true
			assert((scene.wizard.laugh_left>0)==(scene.entry_variant==0))
			scene.cancel_witch_entry()
			for voice in scene.audio.voices:
				assert(not voice.playing)
	assert(seen.size()==3)
	for cue in scene.audio.ENTRY_CUES:
		assert(scene.audio.sounds[cue].get_length()<=1.81)
	scene.audio.set_enabled(false)
	cues.clear()
	scene.begin_witch_entry()
	assert(cues.is_empty())
	scene.cancel_witch_entry()
	scene.audio.set_enabled(true)
	scene.audio.set_suspended("test",true)
	scene.begin_witch_entry()
	assert(cues.is_empty())
	scene.cancel_witch_entry()
	await create_timer(.25).timeout
	scene.free()
	await process_frame
	print("PASS three entrance sounds match animation, both motion modes, cancellation, mute and suspension")
	quit()
