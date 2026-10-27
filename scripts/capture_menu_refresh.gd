extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540,1200)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	for page in ["menu","settings"]:
		scene.show_menu(page)
		await create_timer(.8).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://%s_refresh_preview.png" % page)
	scene.start_game(0)
	await create_timer(.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://footer_refresh_preview.png")
	scene.free()
	quit()
