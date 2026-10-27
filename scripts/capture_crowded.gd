extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	var crowded := 0
	for index in range(scene.levels.size()):
		if scene.levels[index].tubes.size()>scene.levels[crowded].tubes.size(): crowded = index
	for dimensions in [Vector2i(540,840),Vector2i(540,1200)]:
		root.size = dimensions
		await process_frame
		scene.fit_mobile_screen()
		scene.start_game(crowded)
		await create_timer(.2).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://crowded_%d_preview.png" % dimensions.y)
	scene.free()
	quit()
