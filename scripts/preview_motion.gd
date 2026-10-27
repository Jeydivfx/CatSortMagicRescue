extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	# Keep preview capture deterministic even if the window receives input.
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	DirAccess.make_dir_recursive_absolute("res://motion_preview")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://menu_preview.png")
	scene.show_menu("levels")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://levels_preview.png")
	scene.show_menu("settings")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://settings_preview.png")
	scene.start_game(2)
	assert(scene.screen == "game")
	await process_frame
	for frame in range(48):
		assert(scene.screen == "game")
		scene.clock = frame / 12.0
		scene.update_actors()
		if frame >= 30:
			for actor in scene.actors:
				actor.forced_face = 2 if frame < 39 else 3
			scene.update_actors()
		for actor in scene.actors:
			if is_instance_valid(actor.face_tween) and actor.face_tween.is_valid():
				actor.face_tween.custom_step(1.0 / 12.0)
		scene.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://motion_preview/frame_%02d.png" % frame)
		scene.set_process(false)
		await process_frame
	for actor in scene.actors:
		actor.forced_face = -1
	scene.transfer(0, 3)
	scene.flight_tween.pause()
	for frame in range(30):
		if scene.flight_tween.is_valid():
			scene.flight_tween.custom_step(1.0 / 36.0)
		scene.clock += 1.0 / 36.0
		scene.update_actors()
		for actor in scene.actors:
			if is_instance_valid(actor.face_tween) and actor.face_tween.is_valid():
				actor.face_tween.custom_step(1.0 / 36.0)
		scene.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://motion_preview/frame_%02d.png" % (48 + frame))
		if frame == 10:
			root.get_texture().get_image().save_png("res://motion_preview/jump.png")
	scene.update_actors()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://preview.png")
	quit()
