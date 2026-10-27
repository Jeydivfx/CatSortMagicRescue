extends SceneTree

func _initialize() -> void:
	call_deferred("demo")

func demo() -> void:
	root.gui_disable_input = true
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.persistence_enabled = false
	scene.set_process_unhandled_input(false)
	scene.audio.set_enabled(true)
	scene.audio.set_music_enabled(true)
	for i in range(3):
		await create_timer(1.6).timeout
		var actor = scene.menu_cats.get_child(i)
		actor.greet_until = scene.clock + 1.1
		scene.audio.play_cat(actor.kind)
	await create_timer(1.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://menu_preview.png")
