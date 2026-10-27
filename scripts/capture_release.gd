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
	var original_unlocked: int = scene.unlocked
	var original_bests: Dictionary = scene.best_moves.duplicate(true)
	scene.audio.set_enabled(false)
	scene.audio.set_music_enabled(false)
	await shot("res://menu_preview.png")
	scene.start_game(2)
	await create_timer(0.25).timeout
	await shot("res://preview.png")
	scene.request_extra_tube()
	await shot("res://reward_preview.png")
	scene.cancel_reward()
	scene.load_level(0)
	await scene.transfer(0, 2)
	await scene.transfer(1, 0)
	await scene.transfer(2, 1)
	await create_timer(1.1).timeout
	await shot("res://win_preview.png")
	scene.unlocked = original_unlocked
	scene.best_moves = original_bests
	scene.persistence_enabled = true
	scene.audio.set_enabled(scene.sound_enabled)
	scene.audio.set_music_enabled(scene.music_enabled)
	scene.show_menu()
	scene.set_process_unhandled_input(true)
	root.gui_disable_input = false
	print("CAPTURE COMPLETE: home, gameplay, reward preview and victory. Game ready to play.")
