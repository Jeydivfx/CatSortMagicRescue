extends SceneTree

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_music_enabled(false)
	scene.start_game(0)
	assert(scene.wizard.size.y>=180)
	var cues: Array = []
	scene.audio.cue_played.connect(func(name): cues.append(name))
	scene.wizard.last_activity = scene.wizard.age-10
	scene.wizard.next_laugh = scene.wizard.age
	await create_timer(.08).timeout
	assert(cues.count("witch_laugh")==1)
	assert(scene.wizard.next_laugh-scene.wizard.age>15)
	scene.audio.set_enabled(false)
	scene.wizard.last_activity = scene.wizard.age-10
	scene.wizard.next_laugh = scene.wizard.age
	await create_timer(.08).timeout
	assert(cues.count("witch_laugh")==1)
	for gentle in [false,true]:
		scene.reduced_motion = gentle
		for dimensions in [Vector2i(540,840),Vector2i(540,1200)]:
			root.size = dimensions
			await process_frame
			scene.fit_mobile_screen()
			for index in [0,100,999]:
				scene.start_game(index)
				scene.update_actors()
				var bounds: Rect2 = scene.wizard.get_rect()
				for tube in range(scene.tubes.size()): assert(not bounds.intersects(scene.tube_rect(tube)))
				scene.win_at = scene.clock
				var actor = scene.actors[0]
				for elapsed in [.5,1.2,1.7,2.3]:
					scene.clock = scene.win_at+elapsed
					scene.animate_escape(actor,0,0)
					assert(actor.modulate.a==1)
				var full := Rect2(-scene.position,scene.get_viewport_rect().size)
				assert(not full.grow(100).has_point(actor.position))
	print("PASS larger witch, synchronized occasional laugh, mute, board clearance and fully opaque offscreen escape in both motion modes")
	scene.free()
	quit()
