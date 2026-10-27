extends SceneTree

func _initialize() -> void:
	call_deferred("demo")

func demo() -> void:
	root.gui_disable_input = true
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.reduced_motion = false
	scene.set_process_unhandled_input(false)
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(true)
	scene.start_game(0)
	await create_timer(0.5).timeout
	await scene.transfer(0, 2)
	await scene.transfer(1, 0)
	await scene.transfer(2, 1)
	await create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://win_preview.png")
	await create_timer(2.5).timeout
	create_tween().tween_property(scene.audio.music,"volume_db",-60.0,0.4)
	await create_timer(0.45).timeout
	scene.audio.set_music_enabled(false)
	scene.audio.set_enabled(false)
