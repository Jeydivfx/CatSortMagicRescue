extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540,840)
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(false)
	scene.reduced_motion = false
	scene.show_menu()
	await create_timer(5.5).timeout
	scene.start_game(0,true)
	await create_timer(.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://witch_entry_preview.png")
	await create_timer(1.7).timeout
	scene.free()
	quit()
