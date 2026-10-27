extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func capture() -> void:
	root.gui_disable_input = true
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.set_process_unhandled_input(false)
	scene.persistence_enabled = false
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	scene.level_page = 9
	scene.show_menu("levels")
	await shot("res://campaign_preview.png")
	scene.start_game(99)
	await create_timer(.2).timeout
	await shot("res://level_100_preview.png")
	scene.show_menu("settings")
	await shot("res://settings_preview.png")
	scene.level_page = (scene.unlocked - 1) / 10
	scene.persistence_enabled = true
	scene.audio.set_enabled(scene.sound_enabled)
	scene.audio.set_music_enabled(scene.music_enabled)
	scene.show_menu()
	scene.set_process_unhandled_input(true)
	root.gui_disable_input = false
	print("CAPTURE COMPLETE: 100-level map, final level, audio settings; game ready.")
