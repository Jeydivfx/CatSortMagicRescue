extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	var audio = scene.audio
	audio.set_enabled(true)
	audio.set_music_enabled(false)
	assert(audio.music.stream is AudioStreamOggVorbis and audio.music.stream.loop)
	assert(audio.music.stream.resource_path.ends_with("clear_air.ogg"))
	assert(audio.music.stream.get_length()>180)
	audio.set_levels(.35,.5)
	assert(is_equal_approx(audio.music_gain,.35) and is_equal_approx(audio.effects_gain,.5))
	var cues: Array[String] = []
	audio.cue_played.connect(func(name: String): cues.append(name))
	scene.ads.presentation_changed.emit(true)
	audio.play("jump")
	audio.play_cat(0)
	assert(cues.is_empty())
	audio.set_suspended("focus",true)
	scene.ads.presentation_changed.emit(false)
	audio.play("tap")
	assert(cues.is_empty(),"Closing ad must not resume audio while app is unfocused")
	audio.set_suspended("focus",false)
	audio.play_cat(0)
	assert(cues == ["cat"])
	for voice in audio.voices:
		if voice.playing:
			assert(voice.stream.resource_path.contains("sfx_v2/cat_"))
	scene.show_menu("settings")
	var sliders := 0
	var rects: Array[Rect2] = []
	for item in scene.menu_ui.get_children():
		if item is HSlider:
			sliders += 1
		if item is Button or item is HSlider:
			var rect: Rect2 = item.get_rect()
			for previous in rects:
				assert(not previous.intersects(rect),"Settings controls overlap")
			rects.append(rect)
	assert(sliders == 2)
	audio.set_enabled(false)
	await create_timer(.25).timeout
	scene.free()
	await process_frame
	print("PASS Clear Air looping music, dry voice bank, gain controls, ad/focus suspension and non-overlapping settings")
	quit()
